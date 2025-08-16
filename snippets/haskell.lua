local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- curly braces '{}' will insert platform independant newlines between text strings.
return {
    -- Snippet for a block of code to quickly evaluate something with haskell-eval-plugin.
    s('eval', {
        t {
            'foobar :: ()',
            'foobar = undefined',
            '{-',
            '',
            '',
        },
        t '>>> ',
        i(1),
        t {
            '',
            '',
            '-}',
        },
    }),

    -- Snippet for a section divider in a haskell file.
    -- (a 'section divider' is not a formal language construct, it's just a nice aesthetic)
    s('section', {
        t {
            '--------------------------------------------------------------------------------',
            '',
        },
        t '-- ',
        i(1),
        t {
            '',
            '--------------------------------------------------------------------------------',
            '',
        },
    }),
}
