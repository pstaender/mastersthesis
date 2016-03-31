#!/usr/bin/env coffee

process.stdin.on 'data', (s) ->
  line = s.toString().replace(/\n/g, '_newline_')

  replaceRuleset = [
    # remove tables
    [ /\\begin\{(table)\}.*?\\end\{(table)\}/ig, '' ]
    # remove tables
    [ /\\begin\{(tabular)\}.*?\\end\{(tabular)\}/ig, '' ]
    # remove figures
    [ /\\begin\{(figure)\}.*?\\end\{(figure)\}/ig, '' ]
    # remove labels
    [ /\\label\{.+?\}/ig, '' ]
    # remove text formatter
    [ /\\(text|textit|textbf)(\[.+\])*\{(.*?)\}/ig, '$3' ]
    # # transform headers
    [ /\\(section|subsection|subsubsection)(\[.+\])*\{(.*?)\}/ig, '## $3' ]
    # # transform annotations
    [ /\\(cite|ref|footnote|footnotetext|text|textit|textbf|url)(\[[^\]]+\])*\{(.*?)\}/ig, '[$3]' ]
    # # remove comments, now workimg, yet?!
    [ /_newline_\s*%.+?_newline_/ig, '_newline_' ]
    # # clean lists
    [ /\\(begin|end)\{(enumerate|itemize)\}/ig, '' ]
    # # transform lists
    [ /(\s+)\\item\s+/ig, '  * ']
    # # unescape
    [ /\\(.){1}/ig, '$1' ]
  ]

  replaceRuleset.forEach (rule) ->
    line = line.replace(rule[0], rule[1])

  line = line.replace(/_newline_/g, "\n")

  console.log line
