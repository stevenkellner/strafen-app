"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateThumbs = void 0;
const functions = require("firebase-functions");
const storage = require("@google-cloud/storage");
const sharp = require("sharp");
const fs = require("fs-extra");
const os_1 = require("os");
const path_1 = require("path");
const gcs = new storage.Storage();
exports.generateThumbs = functions.region("europe-west1").storage
    .object()
    .onFinalize(async (object) => {
    const bucket = gcs.bucket(object.bucket);
    const filePath = object.name;
    if (filePath == null) {
        return;
    }
    const fileName = filePath.split("/").pop();
    if (fileName == null) {
        return;
    }
    const bucketDir = path_1.dirname(filePath);
    const workingDir = path_1.join(os_1.tmpdir(), "thumbs");
    const tmpFilePath = path_1.join(workingDir, "source.png");
    if (fileName.includes("thumb@") ||
        object.contentType == null ||
        !object.contentType.includes("image") ||
        filePath.split("/").length < 2 ||
        filePath.split("/")[0] != "images" ||
        !(filePath.split("/")[1] == "person" ||
            filePath.split("/")[1] == "club")) {
        return;
    }
    // 1. Ensure thumbnail dir exists
    await fs.ensureDir(workingDir);
    // 2. Download Source File
    await bucket.file(filePath).download({
        destination: tmpFilePath,
    });
    // 3. Resize the images and define an array of upload promises
    const sizes = [64, 128, 256];
    const uploadPromises = sizes.map(async (size) => {
        const thumbName = `thumb@${size}_${fileName}`;
        const thumbPath = path_1.join(workingDir, thumbName);
        // Resize source image
        await sharp(tmpFilePath)
            .resize(size, null)
            .withMetadata()
            .toFile(thumbPath);
        // Upload to GCS
        return bucket.upload(thumbPath, {
            destination: path_1.join(bucketDir, thumbName),
            metadata: {
                contentType: object.contentType,
            },
        });
    });
    // 4. Run the upload operations
    await Promise.all(uploadPromises);
    // 5. Cleanup remove the tmp/thumbs from the filesystem
    return fs.remove(workingDir);
});
//# sourceMappingURL=resizeImage.js.map