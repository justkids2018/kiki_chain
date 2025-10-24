import figmaApi from 'figma-api';

const { Api, Client } = figmaApi;
const FigmaApiCtor = Api ?? Client;

export function createFigmaClient(personalAccessToken) {
  if (!personalAccessToken) {
    throw new Error('Missing Figma personal access token');
  }

  if (!FigmaApiCtor) {
    throw new Error('Unable to locate Figma API constructor');
  }

  return new FigmaApiCtor({ personalAccessToken });
}

export async function fetchNodeDocument(figmaClient, fileKey, nodeId) {
  if (!fileKey) {
    throw new Error('FIGMA_FILE_KEY must be provided via env or input');
  }
  if (!nodeId) {
    throw new Error('nodeId is required');
  }

  let result;
  if (typeof figmaClient.fileNodes === 'function') {
    result = await figmaClient.fileNodes(fileKey, [nodeId]);
  } else if (typeof figmaClient.getFileNodes === 'function') {
    result = await figmaClient.getFileNodes({ file_key: fileKey }, { ids: nodeId });
  } else {
    throw new Error('The Figma client does not support fileNodes/getFileNodes');
  }
  const node = result?.nodes?.[nodeId];
  if (!node || !node.document) {
    throw new Error(`Node ${nodeId} not found in file ${fileKey}`);
  }
  return node.document;
}
