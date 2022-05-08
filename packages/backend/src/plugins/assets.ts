/**
 * A function to read files from google cloud storage.
 * The function takes in the argument of the file path and returns the file content.
 */
import { getRootLogger, loadBackendConfig } from '@backstage/backend-common';
import { Storage } from '@google-cloud/storage';
import { Request, Response } from 'express';

const _readFileFromBucket = async (bucket: string, file: string) =>
  new Promise((resolve, reject) => {
    let buffer = '';
    const storage = new Storage();
    storage
      .bucket(bucket)
      .file(file)
      .createReadStream()
      .on('data', data => (buffer += data))
      .on('end', () => resolve(buffer))
      .on('error', err => reject(err));
  });

export const assets = async (request: Request, response: Response) => {
  const config = await loadBackendConfig({
    argv: process.argv,
    logger: getRootLogger(),
  });

  const bucket = config.getString('assets.bucket');
  const file = request.path.slice(1);
  console.log(bucket);
  console.log(file);

  try {
    const content = await _readFileFromBucket(bucket, file);
    response.status(200).send(content);
  } catch (e: any) {
    response.status(e.code).send({ error: e.message });
  } finally {
    response.end();
  }
};
