import { Title } from '@mantine/core';
import { Components } from 'react-markdown';

const MarkdownComponents: Components = {
  h1: ({ node, ...props }) => <Title {...props} />,
  h2: ({ node, ...props }) => <Title order={2} {...props} />,
  h3: ({ node, ...props }) => <Title order={3} {...props} />,
};

export default MarkdownComponents;
