import 'dotenv/config';
import { createServer, tools } from '@modelcontextprotocol/sdk/server';
import { z } from 'zod';
import { createFigmaClient, fetchNodeDocument } from './figmaClient.js';
import { buildWidgetTree } from './widgetTree.js';
import { generateFlutterWidget } from './generator/flutter.js';

const FIGMA_PAT = process.env.FIGMA_PAT;
const DEFAULT_FILE = process.env.FIGMA_FILE_KEY;

if (!FIGMA_PAT) {
  throw new Error('Missing FIGMA_PAT in environment');
}

const figma = createFigmaClient(FIGMA_PAT);

const server = await createServer({
  name: 'figma-mcp',
  version: '0.1.0'
});

const getMetadataInput = z
  .object({
    nodeId: z.string().min(1, 'nodeId is required'),
    fileKey: z.string().optional()
  })
  .strict();

server.tool(
  tools.zod({
    name: 'figma.get_metadata',
    description: 'Fetch Figma node metadata by node ID',
    inputSchema: getMetadataInput,
    async execute({ nodeId, fileKey }) {
      const resolvedFileKey = fileKey ?? DEFAULT_FILE;
      const document = await fetchNodeDocument(figma, resolvedFileKey, nodeId);
      return {
        nodeId,
        name: document?.name,
        type: document?.type,
        absoluteBoundingBox: document?.absoluteBoundingBox,
        childrenCount: document?.children?.length ?? 0
      };
    }
  })
);

const getWidgetTreeInput = z
  .object({
    nodeId: z.string().min(1),
    fileKey: z.string().optional()
  })
  .strict();

server.tool(
  tools.zod({
    name: 'figma.get_widget_tree',
    description: 'Fetch a normalized widget tree for a Figma node',
    inputSchema: getWidgetTreeInput,
    async execute({ nodeId, fileKey }) {
      const resolvedFileKey = fileKey ?? DEFAULT_FILE;
      const document = await fetchNodeDocument(figma, resolvedFileKey, nodeId);
      const tree = buildWidgetTree(document);
      return {
        nodeId,
        name: document.name,
        type: document.type,
        tree
      };
    }
  })
);

const exportWidgetInput = z
  .object({
    nodeId: z.string().min(1),
    fileKey: z.string().optional()
  })
  .strict();

server.tool(
  tools.zod({
    name: 'figma.export_flutter_widget',
    description: 'Generate a simple Flutter widget snippet from a Figma node',
    inputSchema: exportWidgetInput,
    async execute({ nodeId, fileKey }) {
      const resolvedFileKey = fileKey ?? DEFAULT_FILE;
      const document = await fetchNodeDocument(figma, resolvedFileKey, nodeId);
      const tree = buildWidgetTree(document);

      const className = toClassName(document.name);
      const code = generateFlutterWidget(className, tree);
      return {
        nodeId,
        className,
        fileName: `${toSnakeCase(className)}.dart`,
        code,
        tree
      };
    }
  })
);

await server.listen();

console.log('[figma-mcp] server ready');

function toClassName(name) {
  const cleaned = (name ?? 'GeneratedNode')
    .replace(/[^a-zA-Z0-9]+/g, ' ')
    .trim()
    .split(' ')
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('');
  const sanitized = cleaned.length > 0 ? cleaned : 'GeneratedNode';
  return `${sanitized}Widget`;
}

function toSnakeCase(className) {
  return className
    .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
    .replace(/[-\s]+/g, '_')
    .toLowerCase();
}
