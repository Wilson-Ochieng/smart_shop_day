const functions = require("firebase-functions/v2");
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(cors({origin: true}));
app.use(express.json());

/**
 * ✅ Health Check Endpoint
 */
app.get("/health", (req, res) => {
  res.json({status: "healthy", timestamp: new Date().toISOString()});
});

/**
 * ✅ Helper: Get M-Pesa Access Token
 */
async function getAccessToken() {
  const consumerKey = process.env.MPESA_CONSUMER_KEY;
  const consumerSecret = process.env.MPESA_CONSUMER_SECRET;
  const auth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString(
      "base64",
  );

  const response = await axios.get(
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
      {
        headers: {Authorization: `Basic ${auth}`},
      },
  );

  return response.data.access_token;
}

/**
 * ✅ Initiate STK Push - DEBUG VERSION
 */
app.post("/initiate-stk-push", async (req, res) => {
  console.log("=".repeat(80));
  console.log("📱 STK Push Request Received at:", new Date().toISOString());
  console.log("Request Body:", JSON.stringify(req.body, null, 2));
  console.log("-".repeat(80));

  try {
    const {phone, amount, orderId} = req.body;

    // Validate required fields
    if (!phone || !amount) {
      console.log("❌ VALIDATION ERROR: Missing phone or amount");
      return res.status(400).json({
        error: "Phone number and amount are required",
        received: req.body,
      });
    }

    console.log(`📞 Phone: ${phone}`);
    console.log(`💰 Amount: ${amount}`);
    console.log(`🆔 OrderId: ${orderId || "Not provided"}`);

    // Get access token
    console.log("🔑 Getting access token...");
    const accessToken = await getAccessToken();
    console.log("✅ Access Token Obtained (length):", accessToken.length);

    // Get configuration
    const shortcode = process.env.MPESA_SHORTCODE;
    const passkey = process.env.MPESA_PASSKEY;
    const callbackUrl = process.env.MPESA_CALLBACK_URL;

    console.log("⚙️ Configuration:");
    console.log("  Shortcode:", shortcode);
    console.log(
        "  Passkey (first 10 chars):",
      passkey ? passkey.substring(0, 10) + "..." : "NOT SET",
    );
    console.log("  Passkey length:", passkey ? passkey.length : 0);
    console.log("  Callback URL:", callbackUrl);

    // Validate configuration
    if (!shortcode || !passkey) {
      throw new Error("Missing shortcode or passkey in configuration");
    }

    // Generate timestamp (must be exactly 14 digits)
    const timestamp = new Date()
        .toISOString()
        .replace(/[-:TZ.]/g, "")
        .slice(0, 14);

    console.log("🕒 Generated Timestamp:", timestamp);
    console.log("Timestamp length:", timestamp.length);

    // Generate password (must be base64 encoded)
    const passwordString = shortcode + passkey + timestamp;
    console.log("🔐 Password String:", passwordString.substring(0, 50) + "...");
    const password = Buffer.from(passwordString).toString("base64");
    console.log(
        "🔐 Password (Base64 - first 50 chars):",
        password.substring(0, 50) + "...",
    );

    // Prepare payload for M-Pesa API
    const payload = {
      BusinessShortCode: shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: amount,
      PartyA: phone,
      PartyB: shortcode,
      PhoneNumber: phone,
      CallBackURL: callbackUrl,
      AccountReference: orderId || "ShopSmart",
      TransactionDesc: "Payment for goods",
    };

    console.log("📤 Prepared M-Pesa Payload:");
    console.log(JSON.stringify(payload, null, 2));

    console.log("🚀 Sending request to M-Pesa Sandbox API...");
    console.log(
        "URL: https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
    );

    // Make request to M-Pesa
    const startTime = Date.now();
    const mpesaResponse = await axios.post(
        "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
        payload,
        {
          headers: {
            "Authorization": `Bearer ${accessToken}`,
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
          },
          timeout: 30000, // 30 seconds
          validateStatus: function(status) {
            return status < 500; // Don't throw for 4xx errors
          },
        },
    );
    const endTime = Date.now();

    console.log("✅ M-Pesa API Response Time:", endTime - startTime + "ms");
    console.log("📡 Response Status:", mpesaResponse.status);
    console.log("📡 Response Headers:", JSON.stringify(mpesaResponse.headers));
    console.log(
        "📡 Response Data:",
        JSON.stringify(mpesaResponse.data, null, 2),
    );

    // Check if M-Pesa returned an error
    if (mpesaResponse.data.errorCode || mpesaResponse.data.errorMessage) {
      console.log("❌ M-Pesa API returned error:", mpesaResponse.data);
      throw new Error(
          `M-Pesa Error: ${
            mpesaResponse.data.errorMessage || mpesaResponse.data.errorCode
          }`,
      );
    }

    // Check response code
    if (mpesaResponse.data.ResponseCode !== "0") {
      console.log(
          "❌ M-Pesa ResponseCode not 0:",
          mpesaResponse.data.ResponseCode,
      );
      throw new Error(
          `M-Pesa Error: ${
            mpesaResponse.data.ResponseDescription || "Unknown error"
          }`,
      );
    }

    console.log("🎉 STK Push initiated successfully!");
    console.log("CheckoutRequestID:", mpesaResponse.data.CheckoutRequestID);
    console.log("MerchantRequestID:", mpesaResponse.data.MerchantRequestID);

    // Save to Firestore if orderId provided
    if (orderId && mpesaResponse.data.ResponseCode === "0") {
      try {
        const updateData = {
          checkoutRequestId: mpesaResponse.data.CheckoutRequestID,
          merchantRequestId: mpesaResponse.data.MerchantRequestID,
          mpesaStatus: "stk_push_initiated",
          mpesaResponse: mpesaResponse.data.ResponseDescription,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await db.collection("orders").doc(orderId).update(updateData);
        console.log("✅ Order updated in Firestore:", updateData);
      } catch (firestoreError) {
        console.error(
            "⚠️ Firestore update failed (non-fatal):",
            firestoreError,
        );
        // Don't fail the request because of Firestore
      }
    }

    console.log("=".repeat(80));
    res.json(mpesaResponse.data);
  } catch (error) {
    console.error("🔥 STK PUSH FAILED!");
    console.error("Error Type:", error.constructor.name);
    console.error("Error Message:", error.message);

    if (error.response) {
      console.error("📡 Response Status:", error.response.status);
      console.error("📡 Response Status Text:", error.response.statusText);
      console.error(
          "📡 Response Headers:",
          JSON.stringify(error.response.headers),
      );
      console.error(
          "📡 Response Data:",
          JSON.stringify(error.response.data, null, 2),
      );

      // Special handling for common M-Pesa errors
      if (error.response.data && error.response.data.errorMessage) {
        if (error.response.data.errorMessage.includes("Invalid Access Token")) {
          console.error("❌ INVALID ACCESS TOKEN - Token may have expired");
        } else if (error.response.data.errorMessage.includes("Bad Request")) {
          console.error("❌ BAD REQUEST - Check payload format");
        }
      }
    } else if (error.request) {
      console.error("📡 No response received from M-Pesa API");
      console.error("Request:", error.request);
    }

    console.error("Stack Trace:", error.stack);
    console.error("=".repeat(80));

    // Return detailed error
    res.status(500).json({
      error: "Failed to initiate STK Push",
      details: error.message,
      mpesaError: error.response ? error.response.data : null,
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * ✅ M-Pesa Callback URL
 */
// app.post("/mpesa-callback", async (req, res) => {
//   console.log("M-Pesa Callback:", JSON.stringify(req.body));

//   // Send immediate response to M-Pesa
//   res.status(200).json({
//     ResultCode: 0,
//     ResultDesc: "Success",
//   });

//   // Process callback asynchronously
//   try {
//     const callback = req.body;

//     if (callback.Body && callback.Body.stkCallback) {
//       const stkCallback = callback.Body.stkCallback;
//       const resultCode = parseInt(stkCallback.ResultCode);
//       const checkoutRequestId = stkCallback.CheckoutRequestID;

//       console.log("Processing callback for:", checkoutRequestId);

//       let mpesaStatus = "pending";
//       const mpesaResponse = stkCallback.ResultDesc;

//       if (resultCode === 0) {
//         mpesaStatus = "paid";
//         console.log("✅ Payment successful");
//       } else if (resultCode === 1031 || resultCode === 1032) {
//         mpesaStatus = "cancelled";
//         console.log("❌ Payment cancelled");
//       } else {
//         mpesaStatus = "failed";
//         console.log("❌ Payment failed");
//       }

//       // Find and update order
//       try {
//         const ordersQuery = await db
//             .collection("orders")
//             .where("checkoutRequestId", "==", checkoutRequestId)
//             .limit(1)
//             .get();

//         if (!ordersQuery.empty) {
//           const orderId = ordersQuery.docs[0].id;

//           const updateData = {
//             mpesaStatus: mpesaStatus,
//             mpesaResponse: mpesaResponse,
//             updatedAt: admin.firestore.FieldValue.serverTimestamp(),
//           };

//           // Add receipt number if payment was successful
//           if (
//             resultCode === 0 &&
//             stkCallback.CallbackMetadata &&
//             stkCallback.CallbackMetadata.Item
//           ) {
//             const items = stkCallback.CallbackMetadata.Item;
//             const receiptItem = items.find((item) => {
//               return item.Name === "MpesaReceiptNumber";
//             });
//             if (receiptItem) {
//               updateData.mpesaReceiptNumber = receiptItem.Value;
//               console.log("Receipt Number:", receiptItem.Value);
//             }
//           }

//           await db.collection("orders").doc(orderId).update(updateData);
//           console.log("✅ Order updated:", orderId);
//         } else {
//           console.log(
//               "No order found for checkoutRequestId:",
//               checkoutRequestId,
//           );
//         }
//       } catch (error) {
//         console.error("Error updating order:", error);
//       }
//     }
//   } catch (error) {
//     console.error("Callback processing error:", error);
//   }
// });
app.post("/mpesa-callback", async (req, res) => {
  console.log("=".repeat(80));
  console.log("📞 M-Pesa Callback Received at:", new Date().toISOString());
  console.log("📨 Full Request Body:", JSON.stringify(req.body, null, 2));
  console.log("-".repeat(80));

  // Send immediate response to M-Pesa
  res.status(200).json({
    ResultCode: 0,
    ResultDesc: "Success",
  });

  // Process callback asynchronously
  try {
    const callback = req.body;

    if (!callback.Body || !callback.Body.stkCallback) {
      console.log("⚠️ Invalid callback format");
      return;
    }

    const stkCallback = callback.Body.stkCallback;
    const resultCode = parseInt(stkCallback.ResultCode);
    const checkoutRequestId = stkCallback.CheckoutRequestID;
    const merchantRequestId = stkCallback.MerchantRequestID;
    const resultDesc = stkCallback.ResultDesc;

    console.log(`🆔 CheckoutRequestID: ${checkoutRequestId}`);
    console.log(`🆔 MerchantRequestID: ${merchantRequestId}`);
    console.log(`📊 ResultCode: ${resultCode}`);
    console.log(`📝 ResultDesc: ${resultDesc}`);

    let mpesaStatus = "pending";
    let receiptNumber = null;

    if (resultCode === 0) {
      mpesaStatus = "paid";
      console.log("✅ Payment successful!");
      
      // Extract receipt number
      if (stkCallback.CallbackMetadata && stkCallback.CallbackMetadata.Item) {
        const items = stkCallback.CallbackMetadata.Item;
        const receiptItem = items.find((item) => item.Name === "MpesaReceiptNumber");
        if (receiptItem) {
          receiptNumber = receiptItem.Value;
          console.log("🧾 Receipt Number:", receiptNumber);
        }
      }
    } else if (resultCode === 1031 || resultCode === 1032) {
      mpesaStatus = "cancelled";
      console.log("❌ Payment cancelled");
    } else {
      mpesaStatus = "failed";
      console.log("❌ Payment failed");
    }

    // 🔍 Find and update order - TRY MULTIPLE METHODS
    let orderFound = false;
    let orderId = null;

    // Method 1: Direct query by checkoutRequestId
    console.log(`🔍 Method 1: Searching by checkoutRequestId: ${checkoutRequestId}`);
    let ordersQuery = await db
      .collection("orders")
      .where("checkoutRequestId", "==", checkoutRequestId)
      .limit(1)
      .get();

    if (!ordersQuery.empty) {
      orderFound = true;
      orderId = ordersQuery.docs[0].id;
      console.log(`✅ Found order by checkoutRequestId: ${orderId}`);
    }

    // Method 2: Try by merchantRequestId
    if (!orderFound && merchantRequestId) {
      console.log(`🔍 Method 2: Searching by merchantRequestId: ${merchantRequestId}`);
      ordersQuery = await db
        .collection("orders")
        .where("merchantRequestId", "==", merchantRequestId)
        .limit(1)
        .get();

      if (!ordersQuery.empty) {
        orderFound = true;
        orderId = ordersQuery.docs[0].id;
        console.log(`✅ Found order by merchantRequestId: ${orderId}`);
      }
    }

    // Method 3: Search by orderId from the callback (if it was included)
    if (!orderFound && callback.orderId) {
      console.log(`🔍 Method 3: Checking direct orderId: ${callback.orderId}`);
      const doc = await db.collection("orders").doc(callback.orderId).get();
      if (doc.exists) {
        orderFound = true;
        orderId = callback.orderId;
        console.log(`✅ Found order by direct ID: ${orderId}`);
      }
    }

    // Method 4: Search by scanning recent orders (last resort)
    if (!orderFound) {
      console.log("🔍 Method 4: Scanning recent orders...");
      const recentOrders = await db
        .collection("orders")
        .orderBy("createdAt", "desc")
        .limit(10)
        .get();

      for (const doc of recentOrders.docs) {
        const data = doc.data();
        if (data.checkoutRequestId === checkoutRequestId || 
            data.merchantRequestId === merchantRequestId) {
          orderFound = true;
          orderId = doc.id;
          console.log(`✅ Found order by scanning: ${orderId}`);
          break;
        }
      }
    }

    if (orderFound && orderId) {
      const updateData = {
        mpesaStatus: mpesaStatus,
        mpesaResponse: resultDesc,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (receiptNumber) {
        updateData.mpesaReceiptNumber = receiptNumber;
        updateData.status = "paid";
      }

      console.log(`📝 Updating order ${orderId} with:`, updateData);
      await db.collection("orders").doc(orderId).update(updateData);
      console.log(`✅ Order ${orderId} updated successfully!`);
    } else {
      console.log(`❌❌❌ CRITICAL: No order found for callback`);
      console.log(`   CheckoutRequestID: ${checkoutRequestId}`);
      console.log(`   MerchantRequestID: ${merchantRequestId}`);
      
      // Save to debug collection for investigation
      await db.collection("callback_debug").add({
        checkoutRequestId: checkoutRequestId,
        merchantRequestId: merchantRequestId,
        resultCode: resultCode,
        resultDesc: resultDesc,
        receiptNumber: receiptNumber,
        fullCallback: callback,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log("📝 Saved callback to debug collection");
    }
  } catch (error) {
    console.error("🔥 Callback processing error:", error);
  }
  
  console.log("=".repeat(80));
});


/**
 * ✅ Firebase Secrets Test
 */
app.get("/test-config", (req, res) => {
  res.json({
    consumerKey: process.env.MPESA_CONSUMER_KEY ? "SET" : "NOT SET",
    consumerSecret: process.env.MPESA_CONSUMER_SECRET ? "SET" : "NOT SET",
    shortcode: process.env.MPESA_SHORTCODE ? "SET" : "NOT SET",
    passkey: process.env.MPESA_PASSKEY ? "SET" : "NOT SET",
    callbackUrl: process.env.MPESA_CALLBACK_URL ? "SET" : "NOT SET",
  });
});

/**
 * ✅ Check Payment Status
 */
app.post("/check-payment", async (req, res) => {
  try {
    const {orderId, checkoutRequestId} = req.body;

    if (!orderId && !checkoutRequestId) {
      return res
          .status(400)
          .json({error: "orderId or checkoutRequestId required"});
    }

    let orderDoc;

    if (orderId) {
      orderDoc = await db.collection("orders").doc(orderId).get();
    } else if (checkoutRequestId) {
      const ordersQuery = await db
          .collection("orders")
          .where("checkoutRequestId", "==", checkoutRequestId)
          .limit(1)
          .get();

      if (!ordersQuery.empty) {
        orderDoc = ordersQuery.docs[0];
      }
    }

    if (!orderDoc || !orderDoc.exists) {
      return res.status(404).json({error: "Order not found"});
    }

    const orderData = orderDoc.data();

    res.json({
      orderId: orderDoc.id,
      status: orderData.status || "pending",
      mpesaStatus: orderData.mpesaStatus || "pending",
      mpesaResponse: orderData.mpesaResponse || "Waiting for payment",
      mpesaReceiptNumber: orderData.mpesaReceiptNumber,
      checkoutRequestId: orderData.checkoutRequestId,
      totalAmount: orderData.totalAmount,
      updatedAt: orderData.updatedAt ? orderData.updatedAt.toDate() : null,
    });
  } catch (error) {
    console.error("Check payment error:", error);
    res.status(500).json({error: "Failed to check payment status"});
  }
});

/**
 * ✅ Test M-Pesa Credentials
 */
app.post("/test-mpesa-auth", async (req, res) => {
  try {
    console.log("🔐 Testing M-Pesa authentication...");

    const consumerKey = process.env.MPESA_CONSUMER_KEY;
    const consumerSecret = process.env.MPESA_CONSUMER_SECRET;

    console.log(
        "Consumer Key (first 10 chars):",
      consumerKey ? consumerKey.substring(0, 10) + "..." : "NOT SET",
    );
    console.log(
        "Consumer Secret (first 10 chars):",
      consumerSecret ? consumerSecret.substring(0, 10) + "..." : "NOT SET",
    );

    const auth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString(
        "base64",
    );
    console.log("Auth Header:", `Basic ${auth.substring(0, 20)}...`);

    const response = await axios.get(
        "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
        {
          headers: {
            "Authorization": `Basic ${auth}`,
            "Cache-Control": "no-cache",
          },
          timeout: 10000,
        },
    );

    console.log("✅ Authentication successful!");
    console.log(
        "Access Token (first 20 chars):",
      response.data.access_token ?
        response.data.access_token.substring(0, 20) + "..." :
        "No token",
    );

    res.json({
      success: true,
      message: "Authentication successful",
      tokenLength: response.data.access_token ?
        response.data.access_token.length :
        0,
      expiresIn: response.data.expires_in,
      tokenPreview: response.data.access_token ?
        response.data.access_token.substring(0, 20) + "..." :
        null,
    });
  } catch (error) {
    console.error("❌ Authentication failed!");
    console.error("Error:", error.message);

    if (error.response) {
      console.error("Response Status:", error.response.status);
      console.error(
          "Response Headers:",
          JSON.stringify(error.response.headers),
      );
      console.error("Response Data:", JSON.stringify(error.response.data));

      if (error.response.status === 401) {
        console.error("❌ UNAUTHORIZED - Invalid consumer key or secret!");
        console.error("Tip: Get new credentials from Daraja Portal");
      }
    } else if (error.request) {
      console.error("No response received:", error.request);
    }

    res.status(500).json({
      success: false,
      error: error.message,
      response: error.response ?
        {
          status: error.response.status,
          data: error.response.data,
        } :
        null,
    });
  }
});

/**
 * ✅ Export Express App to Firebase
 */
exports.api = functions.https.onRequest(app);
