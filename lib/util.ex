defmodule Util do
  def full_clear() do
    IO.puts IO.ANSI.clear
    IO.puts "\e[1;1H"
  end

  def splash() do
    "" <>
    "\n'||'''|,  '||`               '||                          '||         " <>
    "\n ||   ||   ||                 ||         ''                ||         " <>
    "\n ||;;;;    ||   '''|.  .|'',  || //`     ||  '''|.  .|'',  || //`     " <>
    "\n ||   ||   ||  .|''||  ||     ||<<       || .|''||  ||     ||<<       " <>
    "\n.||...|'  .||. `|..||. `|..' .|| \\\\.     || `|..||. `|..' .|| \\\\. " <>
    "\n                                         ||                           " <>
    "\n                                      `..|'                           " <>
    "\n"
  end

  def reprint(x \\ "") do
    full_clear
    IO.puts splash
    IO.puts x
  end
end	