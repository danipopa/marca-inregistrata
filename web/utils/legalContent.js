export function legalBlocks(content) {
  const blocks = []
  const paragraph = []
  let list = null

  function flushParagraph() {
    if (!paragraph.length) return

    blocks.push({ type: 'paragraph', text: paragraph.join(' ') })
    paragraph.length = 0
  }

  function flushList() {
    if (!list) return

    blocks.push(list)
    list = null
  }

  for (const rawLine of (content || '').split(/\r?\n/)) {
    const line = rawLine.trim()

    if (!line) {
      flushParagraph()
      flushList()
      continue
    }

    const heading = line.match(/^(#{1,3})\s+(.+)$/)
    if (heading) {
      flushParagraph()
      flushList()
      blocks.push({ type: `h${heading[1].length}`, text: heading[2] })
      continue
    }

    const orderedItem = line.match(/^\d+\.\s+(.+)$/)
    if (orderedItem) {
      flushParagraph()
      if (!list || list.type !== 'ol') list = { type: 'ol', items: [] }
      list.items.push(orderedItem[1])
      continue
    }

    const unorderedItem = line.match(/^[-*]\s+(.+)$/)
    if (unorderedItem) {
      flushParagraph()
      if (!list || list.type !== 'ul') list = { type: 'ul', items: [] }
      list.items.push(unorderedItem[1])
      continue
    }

    flushList()
    paragraph.push(line)
  }

  flushParagraph()
  flushList()

  return blocks
}
