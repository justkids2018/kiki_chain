const indentUnit = '  ';

function indent(level) {
  return indentUnit.repeat(level);
}

function formatNumber(value) {
  if (value === null || value === undefined) return null;
  const rounded = Number.parseFloat(value.toFixed(2));
  return Number.isInteger(rounded) ? `${Math.trunc(rounded)}` : `${rounded}`;
}

function renderPadding(padding) {
  if (!padding) return null;
  const { left = 0, top = 0, right = 0, bottom = 0 } = padding;
  if (left === top && top === right && right === bottom) {
    if (left === 0) return null;
    return `EdgeInsets.all(${formatNumber(left)})`;
  }
  return `EdgeInsets.fromLTRB(${formatNumber(left)}, ${formatNumber(top)}, ${formatNumber(right)}, ${formatNumber(bottom)})`;
}

function renderColor(color) {
  if (!color) return null;
  if (color.startsWith('0x')) {
    return `const Color(${color})`;
  }
  return `const Color(${color})`;
}

function renderTextStyle(props) {
  const segments = [];
  if (props.color) segments.push(`color: ${renderColor(props.color)}`);
  if (props.fontSize) segments.push(`fontSize: ${formatNumber(props.fontSize)}`);
  if (props.fontFamily) segments.push(`fontFamily: '${props.fontFamily}'`);
  if (props.lineHeight && props.fontSize) {
    const height = props.fontSize ? props.lineHeight / props.fontSize : null;
    if (height) segments.push(`height: ${formatNumber(height)}`);
  }
  if (segments.length === 0) return null;
  return `TextStyle(${segments.join(', ')})`;
}

function renderChildren(children, level) {
  if (!children || children.length === 0) return '[]';
  const rendered = children
    .map((child) => renderNode(child, level + 1))
    .filter(Boolean)
    .join(',\n');
  return `[\n${rendered}\n${indent(level)}]`;
}

function renderSpacing(children, spacing, axis) {
  if (!spacing || spacing <= 0 || !children || children.length < 2) {
    return children;
  }
  const gap = {
    type: 'sizedBox',
    props: axis === 'vertical' ? { height: spacing } : { width: spacing }
  };
  const enriched = [];
  children.forEach((child, index) => {
    enriched.push(child);
    if (index < children.length - 1) {
      enriched.push(gap);
    }
  });
  return enriched;
}

function renderNode(node, level = 2) {
  if (!node) return null;
  switch (node.type) {
    case 'column': {
      const childrenWithSpacing = renderSpacing(node.children, node.props.spacing, 'vertical');
      const childrenCode = renderChildren(childrenWithSpacing, level + 1);
      const props = [
        `crossAxisAlignment: CrossAxisAlignment.${node.props.crossAxisAlignment ?? 'start'}`,
        `mainAxisAlignment: MainAxisAlignment.${node.props.mainAxisAlignment ?? 'start'}`,
        `children: ${childrenCode}`
      ];
      return `${indent(level)}Column(\n${indent(level + 1)}${props.join(`,\n${indent(level + 1)}`)}\n${indent(level)})`;
    }
    case 'row': {
      const childrenWithSpacing = renderSpacing(node.children, node.props.spacing, 'horizontal');
      const childrenCode = renderChildren(childrenWithSpacing, level + 1);
      const props = [
        `crossAxisAlignment: CrossAxisAlignment.${node.props.crossAxisAlignment ?? 'center'}`,
        `mainAxisAlignment: MainAxisAlignment.${node.props.mainAxisAlignment ?? 'start'}`,
        `children: ${childrenCode}`
      ];
      return `${indent(level)}Row(\n${indent(level + 1)}${props.join(`,\n${indent(level + 1)}`)}\n${indent(level)})`;
    }
    case 'container': {
      const props = [];
      if (node.props.width) props.push(`width: ${formatNumber(node.props.width)}`);
      if (node.props.height) props.push(`height: ${formatNumber(node.props.height)}`);
      const padding = renderPadding(node.props.padding);
      if (padding) props.push(`padding: ${padding}`);
      if (node.props.backgroundColor) {
        props.push(
          `decoration: BoxDecoration(color: ${renderColor(node.props.backgroundColor)})`
        );
      }
      if (node.children && node.children.length > 0) {
        const childCode = renderNode(node.children[0], level + 2);
        if (childCode) props.push(`child: \n${childCode}`);
      }
      return `${indent(level)}Container(${props.join(', ')})`;
    }
    case 'text': {
      const style = renderTextStyle(node.props);
      const props = [`'${(node.props.value ?? '').replace(/'/g, "\\'")}'`];
      if (style) props.push(`style: ${style}`);
      if (node.props.textAlign)
        props.push(`textAlign: TextAlign.${node.props.textAlign}`);
      return `${indent(level)}Text(${props.join(', ')})`;
    }
    case 'rectangle': {
      const props = [];
      if (node.props.width) props.push(`width: ${formatNumber(node.props.width)}`);
      if (node.props.height) props.push(`height: ${formatNumber(node.props.height)}`);
      const decorationParts = [];
      if (node.props.color) decorationParts.push(`color: ${renderColor(node.props.color)}`);
      if (node.props.cornerRadius)
        decorationParts.push(`borderRadius: BorderRadius.circular(${formatNumber(node.props.cornerRadius)})`);
      if (decorationParts.length > 0) {
        props.push(`decoration: BoxDecoration(${decorationParts.join(', ')})`);
      }
      if (props.length === 0) return `${indent(level)}Container()`;
      return `${indent(level)}Container(${props.join(', ')})`;
    }
    case 'sizedBox': {
      const props = [];
      if (node.props.width) props.push(`width: ${formatNumber(node.props.width)}`);
      if (node.props.height) props.push(`height: ${formatNumber(node.props.height)}`);
      return `${indent(level)}SizedBox(${props.join(', ')})`;
    }
    default:
      return `${indent(level)}const SizedBox()`;
  }
}

export function generateFlutterWidget(className, widgetTree) {
  const widgetCode = renderNode(widgetTree, 3) ?? `${indent(3)}const SizedBox()`;
  const lines = widgetCode.split('\n');
  const baseIndent = indent(3);
  const baseRegex = new RegExp(`^${baseIndent}`);

  if (lines.length === 0) {
    lines.push('');
  }

  if (baseRegex.test(lines[0])) {
    lines[0] = lines[0].replace(baseRegex, `${indent(2)}return `);
  } else {
    lines[0] = `${indent(2)}return ${lines[0].trimStart()}`;
  }

  for (let i = 1; i < lines.length; i += 1) {
    lines[i] = baseRegex.test(lines[i])
      ? lines[i].replace(baseRegex, indent(2))
      : `${indent(2)}${lines[i].trimStart()}`;
  }

  const lastIndex = lines.length - 1;
  if (!lines[lastIndex].trimEnd().endsWith(';')) {
    lines[lastIndex] = `${lines[lastIndex]};`;
  }

  const buildBody = lines.join('\n');

  return `import 'package:flutter/material.dart';\n\nclass ${className} extends StatelessWidget {\n  const ${className}({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n${buildBody}\n  }\n}\n`;
}
