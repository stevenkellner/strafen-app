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

const gateway = new braintree.BraintreeGateway({
    environment: braintree.Environment.Sandbox,
    merchantId: keys.merchantId,
    publicKey: keys.publicKey,
    privateKey: keys.privateKey
});

app.post("/client_token", (req, res) => {
    if (req.body.privateKey != keys.privatePaymentKey) { 
        res.send("{'error': 'Private key is invalid'}");
        return;
    }
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

// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}`);
    console.log('Press Ctrl+C to quit.');
});

module.exports = app;
