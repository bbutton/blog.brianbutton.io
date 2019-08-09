---
title: Powershell script to convert RTF docs to plain text using MS-Word
author: Brian Button
type: post
date: 2007-03-13T14:06:00+00:00
url: /index.php/2007/03/13/powershell-script-to-convert-rtf-docs-to-plain-text-using-ms-word/
sfw_comment_form_password:
  - i9w9a664XTAO
sfw_pwd:
  - 8298B49hFoil
categories:
  - Uncategorized

---
On our current project, we had a bunch of RTF files that had some text in them that we wanted to yank out and store in a database. Instead of laboriously opening and resaving each of the files as plaintext, I decided to write what I had hoped would be a simple PowerShell script to do that for me. What follows is my best try at that script. 

I am very open to any questions, criticisms, and improvements in the script, as I&#8217;m still very much learning the language. And my fundamental question is really, was PS the right tool to use for this job?

Enjoy!

&#8212; bab

=============== Reformat.ps1 ================

<pre class="code">function translate_from_rtf_to_text([System.Io.FileInfo] $source_file)
{
    $source_file_name = $source_file.FullName
    $dest_file_name = create_destination_file_name($source_file)

    write-host "Copying from $source_file to $dest_file_name"

    $rtf = $word.Documents.Open($source_file_name)
    $rtf.SaveAs([ref]$dest_file_name, [ref]$saveFormat)
}

function create_destination_file_name([System.Io.FileInfo] $source_file)
{
    $dest_file_name = $source_file.Name.Remove($source_file.Name.Length - $source_file.Extension.Length) + ".txt"
    $dest_directory = $source_file.DirectoryName
    $dest_file = join-path $dest_directory $dest_file_name

    return $dest_file
}

if ($args.Length -ne 1)
{
   write-host "Usage: Reformat.ps1 &lt;path to root directory of rtf files&gt;"
   exit 1
}

$path = $args[0]

write-host Converting all rtf files under directory $path...

$word = new-object -com Word.Application

$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatTextLineBreaks")

get-childitem -path $path -include *.rtf -recurse | foreach-object -process { translate_from_rtf_to_text $_ }

$word.Quit([ref]$true)
</pre>

[][1]

 [1]: http://11011.net/software/vspaste