// Copyright 2017 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

const express = require('express');
const braintree = require('braintree');
const keys = require('./privateKeys');

const app = express();
app.use(express.json());

const sandboxGateway = new braintree.BraintreeGateway({
    environment: braintree.Environment.Sandbox,
    merchantId: keys.sandboxMerchantId,
    publicKey: keys.sandboxPublicKey,
    privateKey: keys.sandboxPrivateKey
});

const prodGateway = new braintree.BraintreeGateway({
    environment: braintree.Environment.Production,
    merchantId: keys.merchantId,
    publicKey: keys.publicKey,
    privateKey: keys.privateKey
});

app.post("/client_token", (req, res) => {
    if (req.body.privateKey != keys.privatePaymentKey) { 
        res.send("{'error': 'Private key is invalid'}");
        return;
    }
    const gateway = req.body.debug == "true" ? sandboxGateway : prodGateway;
    gateway.clientToken.generate({}, (error, response) => {
        if (error) {
            res.send(`{"error": "${error}"}`);
            return;
        }
        res.send(`{"result": "${response.clientToken}"}`);
    });
});

app.post("/checkout", (req, res) => {
    if (req.body.privateKey != keys.privatePaymentKey) { 
        res.send("{'error': 'Private key is invalid'}");
        return;
    }
    const nonceFromClient = req.body.paymentMethodNonce;
    const amount = req.body.amount;
    const deviceData = req.body.deviceData;
    const clubId = req.body.clubId;
    const fineIds = req.body.fineIds;
    let customFields = {
        club_id: clubId,
        fine_ids: fineIds
    };
    const gateway = req.body.debug == "true" ? sandboxGateway : prodGateway;
    gateway.transaction.sale({
        amount: amount,
        paymentMethodNonce: nonceFromClient,
        deviceData: deviceData,
        options: {
            submitForSettlement: true
        },
        customFields: customFields
    }, (error, result) => {
        if (error) {
            res.send(`{"error": "${error}"}`);
            return;
        }
        res.send(`{"result": ${JSON.stringify(result)}}`);
    });
});

app.post("/check_transaction", (req, res) => {
    if (req.body.privateKey != keys.privatePaymentKey) { 
        res.send("{'error': 'Private key is invalid'}");
        return;
    }
    const transactionId = req.body.transactionId;
    const gateway = req.body.debug == "true" ? sandboxGateway : prodGateway;
    gateway.transaction.find(transactionId, (error, transaction) => {
        if (error) {
            res.send(`{"error": "${error}"}`);
            return;
        }
        res.send(`{"result": "${transaction.status}"}`);
    });
});

app.post("/get_transaction", (req, res) => {
    if (req.body.privateKey != keys.privatePaymentKey) { 
        res.send("{'error': 'Private key is invalid'}");
        return;
    }
    const transactionId = req.body.transactionId;
    const gateway = req.body.debug == "true" ? sandboxGateway : prodGateway;
    gateway.transaction.find(transactionId, (error, transaction) => {
        if (error) {
            res.send(`{"error": "${error}"}`);
            return;
        }
        res.send(`{"result": ${JSON.stringify(transaction)}}`);
    });
});

app.post("/all_transactions", (req, res) => {
    if (req.body.privateKey != keys.privatePaymentKey) { 
        res.send("{'error': 'Private key is invalid'}");
        return;
    }
    const clubId = req.body.clubId;
    const gateway = req.body.debug == "true" ? sandboxGateway : prodGateway;
    gateway.transaction.search((search) => {
        search.customerId().isNot("");
      }, (error, response) => {
        if (error) {
            res.send(`{"error": "${error}"}`);
            return;
        }
        Promise.all(response.ids.map(id => {
            return gateway.transaction.find(id);
        })).then(transactions => {
            res.send(`{"result": ${JSON.stringify(transactions.filter(transaction => {
                return transaction.customFields.clubId == clubId;
            }))}}`);
        });
      });
});

// Start the server
app.listen(process.env.PORT || 8080, () => {});

module.exports = app;
