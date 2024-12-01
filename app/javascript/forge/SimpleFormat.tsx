import React from 'react'

interface SimpleFormatData {
  text: string;
  wrapperTag?: string;
  wrapperTagProps?: object;
  postfix?: string;
}

const pattern = /([^\n]\n)(?=[^\n])/g

const toParagraphs = function(text: string): string[] {
  return text.replace(/\r\n?/g, '\n').split(/\n\n+/).map((t) => {
    if (t.match(pattern)) {
      return t.replace(pattern, '$1<br />')
    } else {
      return t
    }
  })
}

const SimpleFormat = (props: SimpleFormatData): React.ReactNode => {
  // Based on:
  // https://github.com/rails/rails/blob/312485f3e88af3966b586275ae5097198bfef6a0/actionview/lib/action_view/helpers/text_helper.rb#L454-L460

  let { wrapperTag, wrapperTagProps, postfix } = props
  wrapperTag = wrapperTag || 'div'
  const text = toParagraphs(props.text)

  if (!text.length) return null

  if (text.length === 1 && text[0].match(/<p>/)) {
    const props = { ...wrapperTagProps, dangerouslySetInnerHTML: { __html: text[0] } }
    return React.createElement(wrapperTag, props)
  }

  return React.createElement(wrapperTag, wrapperTagProps, text.map((paragraph, index) => (
    (postfix && index === text.length - 1)
      ? <p key={ index }>
        <span dangerouslySetInnerHTML={{ __html: paragraph }} />
        { postfix }
      </p>
      : <p key={ index } dangerouslySetInnerHTML={{ __html: paragraph }} />
  )))
}

export default SimpleFormat
