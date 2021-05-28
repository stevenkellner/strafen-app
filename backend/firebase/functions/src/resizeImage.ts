import * as functions from "firebase-functions";
import * as storage from "@google-cloud/storage";
import sharp from "sharp";
import * as fs from "fs-extra";
import {tmpdir} from "os";
import {join, dirname} from "path";

const firebaseStorage = new storage.Storage();

export const generateThumbs = functions.region("europe-west1").storage.object().onFinalize(async (object) => {
    const bucket = firebaseStorage.bucket(object.bucket);
    const filePath = object.name;
    if (filePath == null) {
        return;
    }
    const fileComponents = filePath.split("/");
    if (fileComponents.length != 4) {
        return;
    }
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const fileName = fileComponents.pop()!;
    const dirName = dirname(filePath);
    const tmpWorkingDir = join(tmpdir(), "thumbs", fileComponents[2]);
    const tmpFilePath = join(tmpWorkingDir, "source.jpeg");

    if (fileName.includes("thumb@") ||
      object.contentType == null ||
      !object.contentType.includes("image") ||
      fileComponents[0] != "images" ||
      fileComponents[1] == "person" ||
      fileComponents[1] == "club") {
        return;
    }

    // 1. Ensure thumbnail dir exists
    await fs.ensureDir(tmpWorkingDir);

    // 2. Download Source File
    await bucket.file(filePath).download({
        destination: tmpFilePath,
    });

    // 3. Resize the images and define an array of upload promises
    const sizes = [64, 128, 256];
    for (let index = 0; index < sizes.length; index++) {
        const size = sizes[index];
        const thumbName = `thumb@${size}`;
        const thumbPath = join(tmpWorkingDir, thumbName);

        // Resize source image
        await sharp(tmpFilePath)
            .resize(size, null)
            .withMetadata()
            .toFile(thumbPath);

        // Upload to GCS
        await bucket.upload(thumbPath, {
            destination: join(dirName, thumbName),
            metadata: {
                contentType: object.contentType,
            },
        });
    }

    // 5. Cleanup remove the tmp/thumbs from the filesystem
    await fs.remove(tmpWorkingDir);
});
