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

const app = express();
app.use(express.json());

const gateway = new braintree.BraintreeGateway({
    environment: braintree.Environment.Sandbox,
    merchantId: "p8tggkyhz5tyv9dc",
    publicKey: "yrzxm59rkyh3s3fp",
    privateKey: "80f697cf35b8febd663a8f6c25d75231"
});

app.get("/client_token", (req, res) => {
    gateway.clientToken.generate({}, (error, response) => {
        if (error) {
            res.statusCode(400).send(error);
            return;
        }
        res.send(response.clientToken);
    });
});

app.post("/checkout", (req, res) => {
    const nonceFromClient = req.body.paymentMethodNonce;
    const amount = req.body.amount;
    const deviceData = req.body.deviceData;
    gateway.transaction.sale({
        amount: amount,
        paymentMethodNonce: nonceFromClient,
        deviceData: deviceData,
        options: {
            submitForSettlement: true
        }
    }, (error, result) => {
        if (error) {
            res.statusCode(400).send(error);
            return;
        }
        res.send(result);
    });
});

// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}`);
    console.log('Press Ctrl+C to quit.');
});

module.exports = app;
