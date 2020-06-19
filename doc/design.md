# Design Rationale

## Priority of design
1. Consistent editing logic
2. Faithful rendering of additional features if not conflicting with editing logic.
3. Fast re-rendering on editing
4. Good layout on constrained screen sizes
5. Simple and declarative code
6. Fast parsing and rendering

## AST

The AST of this project has a very similar structure compared with MathML, the AST of MathJax, with several differences:

- MultiscriptNode do not support extra pairs of postscripts as <mmultiscripts> in MathML does. Extra postscript pairs conflict with UnicodeMath input syntax. 
- <msubsup> and part of <mmultiscripts> are merged into one single MultiscriptsNode. After removing the support of extra postscript feature, they become largely the same. In current TeX height/depth calculation mechanism, nesting subsups with presubscripts will fail to generate aligned scripts. We have to merge it into one node anyway.
- Math functions with limit-like subscript and superscript will not be adaptive to different styles. This is due to the design of AST, and is in accordance with UnicodeMath designs. This is different from TeX spec.
- \color commands inside a block will NOT affect right delimiters. This is different from KaTeX and in accordance with MathJax. It is more consistent for our AST design better.
- Matrix won't render multiple \hlines and || column separators, just as MathJax won't either.
- \dfrac, \tfrac ... will be rendered slightly different from KaTeX and will be in line with MathJax's rendering behavior. KaTeX has an `adjustStyle` function whose behvior we have no intention to follow. 


KaTeX functionalities that need further investigation
- xArrow (arrow.js)
- char
- enclose
- horizBrace
- htmlmathml
- mclass
- overline
- phantom
- raisebox
- rule
- underline
- Custom fonts added by plugins
- spacing (maybe need to delete spacings in symbols.dart)


KaTeX functionalities that we won't support
- href
- includegraphics
- lap
- mathchoice
- smash

variantForm is basically in line with MathJax, for the exception of \u210F(\hbar)


The AST uses Roslyn's immutable Red-Green Tree (without deduplication features) to construct the AST. And the GreenNodes are completely stateless and context-free.
- In the build process, this ensures a uni-directional data flow. Options down, widgets up.
- It is simpler to perform widget reusing. As long as the GreenNode and relevant Options stay the same, the entire subtree can be bypassed. And this simple mechanism will cover ALL possible widget reusing scenarios, as the flutter widget tree itself is immutable as well.
- It is tremendously easier and more robust to revert any editing changes. You just need to find the old root node.
- Any layout parameters can be safely calculated and stored inside AST nodes.


## Rendering
- Tex's height and depth calculations are performed implicitly by the layout process of RenderObjects. The height and depth information is carried by MathOrd widget and propagated during widget composition. I feel this is better and simpler than using widget-layer parameters to override existing everyday render-layer behaviors.
- Other Tex's font specs are calculated inside AST nodes and passed explicitly into dedicated layout widgets. Incorporating them (e.g. italic) into RenderObject will cause heavy compatibility burdens (as the breakable RenderObject has already caused) with no real benefits, since the AST is already efficient at calculating and reusing these parameters.
- (WIP) Breakable RenderObjects are made subclasses of RenderBox, which caused huge amount of boilerplate code and exception spots. But we have no choice since we need the interop between RenderBox and breakable ones.
- A large amount of layouts are expressed by custom IntrinsicLayoutDelegate. This is due to the observation that most math nodes will disregard constraints during layout, and its horizontal resizing does not influence vertical layout, and vice versa. IntrinsicLayoutDelegate is hugely concise and efficient in this scenario.


## Symbols and Font
KaTeX use mode (math/text) to directly map commands depending on context into different replacement atoms + atom types + font family. The atom will first try to use explicit contextual font. If not available, it will fall back to default font provided by atom type and font family. (With the exception of wide chars)

Due to the need of editing and copy/pasting, we need to maintain an independent, Unicode-based AST character set. We chose a method similar to MathJax. Unicode char + variantForm uniquely define a symbol. Each symbol has its default replacement, types and font settings, but they can only be overrided when they are constructed by the compiler. Likewise, the symbol will first try to use explicit contextual font. If not available, it will fall back. Any chars using a replacement will never be able to override their font family. (with some exceptions on some punctuations which KaTeX choose to use replacement).