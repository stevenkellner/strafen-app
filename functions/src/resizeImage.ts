import * as functions from "firebase-functions";
import * as storage from "@google-cloud/storage";
import * as sharp from "sharp";
import * as fs from "fs-extra";
import {tmpdir} from "os";
import {join, dirname} from "path";

const gcs = new storage.Storage();

export const generateThumbs = functions.region("europe-west1").storage
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
      const bucketDir = dirname(filePath);

      const workingDir = join(tmpdir(), "thumbs");
      const tmpFilePath = join(workingDir, "source.png");

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
        const thumbPath = join(workingDir, thumbName);

        // Resize source image
        await sharp(tmpFilePath)
            .resize(size, null)
            .withMetadata()
            .toFile(thumbPath);

        // Upload to GCS
        return bucket.upload(thumbPath, {
          destination: join(bucketDir, thumbName),
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
