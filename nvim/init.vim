call plug#begin('~/.local/share/nvim/plugged')
" Плагин для парных скобок
Plug 'jiangmiao/auto-pairs'
" Плагины для автодополнения
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Подсветка синтаксиса и улучшения для Python и C++
Plug 'sheerun/vim-polyglot'

call plug#end()

" Настройки CoC
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : "\<CR>"

" Использовать <c-space> для вызова автодополнения
inoremap <silent><expr> <c-space> coc#refresh()

" Показ диагностики
nnoremap <silent> <leader>d :CocDiagnostics<CR>

" Переход к определению
nnoremap <silent> gd :call CocAction('jumpDefinition')<CR>

" Базовые настройки Neovim
set number
" set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set hidden
set updatetime=300
set shortmess+=c

" Форматирование кода
nmap <leader>f :call CocAction('format')<CR>

" Автоформатирование при сохранении (опционально)
augroup autoformat
  autocmd!
  autocmd BufWritePre *.py,*.cpp,*.hpp :call CocAction('format')
augroup END









