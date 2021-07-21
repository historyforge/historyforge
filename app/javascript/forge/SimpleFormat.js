import React, { Component, createElement } from 'react'

class SimpleFormat extends Component {
    // static propTypes = {
    //     text: PropTypes.string.isRequired,
    //     wrapperTag: PropTypes.oneOfType([
    //         PropTypes.string,
    //         PropTypes.object
    //     ]),
    //     wrapperTagProps: PropTypes.object,
    //     postfix: PropTypes.node
    // }

    static defaultProps = {
        wrapperTag: 'div',
        wrapperTagProps: {}
    }

    // Based on:
    // https://github.com/rails/rails/blob/312485f3e88af3966b586275ae5097198bfef6a0/actionview/lib/action_view/helpers/text_helper.rb#L454-L460
    paragraphs () {
        const pattern = /([^\n]\n)(?=[^\n])/g
        const { text } = this.props
        // const text = sanitizeHtml(this.props.text)
        return text && text.replace(/\r\n?/g, '\n').split(/\n\n+/).map((t) => {
            if (t.match(pattern)) {
                return t.replace(pattern, '$1<br />')
            } else {
                return t
            }
        })
    }

    render () {
        const { wrapperTag, wrapperTagProps, postfix } = this.props
        const text = this.paragraphs();
        if (text.length === 1 && text[0].match(/\<p\>/)) {
            const props = {...wrapperTagProps, dangerouslySetInnerHTML: { __html: text[0] } }
            return createElement(wrapperTag, props)
        }
        return createElement(wrapperTag, wrapperTagProps, text.map((paragraph, index) => (
            (postfix && index === this.paragraphs().length - 1)
                ? <p key={ index }>
                    <span dangerouslySetInnerHTML={{ __html: paragraph }} />
                    { postfix }
                </p>
                : <p key={ index } dangerouslySetInnerHTML={{ __html: paragraph }} />
        )))
    }
}

export default SimpleFormat
