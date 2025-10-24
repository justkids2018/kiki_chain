const AUTO_LAYOUT_MODE = {
  HORIZONTAL: 'HORIZONTAL',
  VERTICAL: 'VERTICAL'
};

const ALIGNMENT_MAP = {
  MIN: 'start',
  CENTER: 'center',
  MAX: 'end',
  SPACE_BETWEEN: 'spaceBetween'
};

function toColorHex(fill) {
  if (!fill || fill.type !== 'SOLID' || !fill.color) {
    return null;
  }
  const { r, g, b } = fill.color;
  const alpha = fill.opacity ?? fill.color.a ?? 1;
  const clamp255 = (value) => Math.round((value ?? 0) * 255);
  const toHex = (value) => clamp255(value).toString(16).padStart(2, '0');
  return `0x${toHex(alpha)}${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
}

function extractFills(fills) {
  if (!Array.isArray(fills) || fills.length === 0) {
    return null;
  }
  for (const fill of fills) {
    const color = toColorHex(fill);
    if (color) {
      return color;
    }
  }
  return null;
}

function convertLayout(node) {
  if (node.layoutMode === AUTO_LAYOUT_MODE.HORIZONTAL) {
    return {
      type: 'row',
      props: {
        spacing: node.itemSpacing ?? 0,
        padding: extractPadding(node),
        mainAxisAlignment: ALIGNMENT_MAP[node.primaryAxisAlignItems] ?? 'start',
        crossAxisAlignment: ALIGNMENT_MAP[node.counterAxisAlignItems] ?? 'start'
      }
    };
  }

  if (node.layoutMode === AUTO_LAYOUT_MODE.VERTICAL) {
    return {
      type: 'column',
      props: {
        spacing: node.itemSpacing ?? 0,
        padding: extractPadding(node),
        mainAxisAlignment: ALIGNMENT_MAP[node.primaryAxisAlignItems] ?? 'start',
        crossAxisAlignment: ALIGNMENT_MAP[node.counterAxisAlignItems] ?? 'start'
      }
    };
  }

  return {
    type: 'container',
    props: {
      padding: extractPadding(node)
    }
  };
}

function extractPadding(node) {
  if (!node) return null;
  const { paddingLeft, paddingTop, paddingRight, paddingBottom } = node;
  if (
    [paddingLeft, paddingTop, paddingRight, paddingBottom].every(
      (value) => value === undefined || value === 0
    )
  ) {
    return null;
  }
  return {
    left: paddingLeft ?? 0,
    top: paddingTop ?? 0,
    right: paddingRight ?? 0,
    bottom: paddingBottom ?? 0
  };
}

function convertText(node) {
  const fillColor = extractFills(node.fills);
  return {
    type: 'text',
    name: node.name,
    props: {
      value: node.characters ?? '',
      color: fillColor,
      fontSize: node.style?.fontSize ?? null,
      fontFamily: node.style?.fontFamily ?? null,
      lineHeight: node.style?.lineHeightPx ?? null,
      textAlign: node.style?.textAlignHorizontal?.toLowerCase() ?? null
    },
    children: []
  };
}

function convertRectangle(node) {
  const fillColor = extractFills(node.fills);
  return {
    type: 'rectangle',
    name: node.name,
    props: {
      width: node.absoluteBoundingBox?.width ?? null,
      height: node.absoluteBoundingBox?.height ?? null,
      color: fillColor,
      cornerRadius: Array.isArray(node.rectangleCornerRadii)
        ? node.rectangleCornerRadii[0]
        : node.cornerRadius ?? null
    },
    children: []
  };
}

function convertGenericFrame(node) {
  const layout = convertLayout(node);
  const children = Array.isArray(node.children)
    ? node.children
        .map(convertNodeToWidget)
        .filter(Boolean)
    : [];

  const size = node.absoluteBoundingBox ?? {};

  return {
    type: layout.type,
    name: node.name,
    props: {
      width: size.width ?? null,
      height: size.height ?? null,
      padding: layout.props.padding,
      spacing: layout.props.spacing,
      mainAxisAlignment: layout.props.mainAxisAlignment,
      crossAxisAlignment: layout.props.crossAxisAlignment,
      backgroundColor: extractFills(node.fills)
    },
    children
  };
}

function convertNodeToWidget(node) {
  if (!node) return null;
  switch (node.type) {
    case 'TEXT':
      return convertText(node);
    case 'RECTANGLE':
    case 'ELLIPSE':
      return convertRectangle(node);
    case 'FRAME':
    case 'GROUP':
    case 'COMPONENT':
    case 'INSTANCE':
    case 'COMPONENT_SET':
      return convertGenericFrame(node);
    default:
      return null;
  }
}

export function buildWidgetTree(rootNode) {
  const tree = convertNodeToWidget(rootNode);
  if (!tree) {
    throw new Error(`Unsupported root node type: ${rootNode?.type}`);
  }
  return tree;
}
