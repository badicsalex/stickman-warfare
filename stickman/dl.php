<?php

$updating=1;

$pos = strpos($_SERVER['REQUEST_URI'],'?');

if (!($pos === false))
{
     header('Expires: 0');
    header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
    header('Pragma: public');

 ?>
<html>
<head>
 <title>Updating</title>
</head>

<body bgcolor="#000000" link="#0000ff" alink="#ff0000" vlink"#0000ff" text="#db5000">
<center>
<h1>The game is being updated!</h1>
You can download a new version in a few minutes,please wait!
<br><br>
<h1>A játék épp frissül</h1>
Egy új verziót tölthet le pár perc múlva, kérem várjon egy picit!
<br>
<table><tr height=200 valign=bottom><td>
<script type="text/javascript"><!--
google_ad_client = "pub-6591027769610148";
/* Letöltés alatt */
google_ad_slot = "3457124547";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</td></tr></table>
</body>
</html>

<?php
exit;
};



error_reporting(0);

 

function traverseDirTree($base,$fileFunc,$dirFunc=null,$afterDirFunc=null){
  $subdirectories=opendir($base);
  while (($subdirectory=readdir($subdirectories))!==false){
    $path=$base.$subdirectory;
    if (is_file($path)){
      if ($fileFunc!==null) $fileFunc($path);
    }else{
      if ($dirFunc!==null) $dirFunc($path);
      if (($subdirectory!='.') && ($subdirectory!='..')){
        traverseDirTree($path.'/',$fileFunc,$dirFunc,$afterDirFunc);
      }
      if ($afterDirFunc!==null) $afterDirFunc($path);
    }
  }
}


function MakeDirs($dir){
 $dir='gzed/'.$dir;
    if (!is_dir($dir)){
        if (!mkdir($dir, 0777, 1)){
        return FALSE;
        }
      } 
}


function CompressAndAdd($nam){
 global $filenevek;
 $gznam='gzed/'.$nam.'.gz';
 $doit=true;
 if (file_exists($gznam)) 
  if (filemtime($gznam)>=filemtime($nam))
   $doit=false; 

 if ($doit) {
  // open file for writing with 8 compression
  $zp = gzopen($gznam, "w8");
  // write string to file
  gzwrite($zp, file_get_contents($nam));
  // close file
  gzclose($zp);
 };
 $filenevek[]=$gznam; 
};

function Listfiles($nam)
{
 global $kimenet, $filehead, $sizeall;
 $nam2=substr($nam,14,strlen($nam)-17);
 echo $nam2."\r\n";
 echo filesize($nam)."\r\n";
 // readfile($nam);
}

traverseDirTree('stickman/',CompressAndAdd,MakeDirs);

ob_start();
if (strstr($_SERVER['REQUEST_URI'],'?')=='?portable')
  readfile('portable.exe');
else
  readfile('installer.exe');
$sizefile=0;
for ($i=0;$i<count($filenevek);$i++)
  {
   listfiles($filenevek[$i]);
   $sizefile += filesize($filenevek[$i]);
  };

echo "\r\n";
$sizehead = ob_get_length();

$filetype = 'application/octet-stream';
if (true) {
header('Content-Description: File Transfer');
header('Content-Type: '.$filetype);
header('Content-Disposition: attachment; filename="SMWF Installer.exe"');
    header('Content-Transfer-Encoding: binary');
    header('Expires: 0');
    header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
    header('Pragma: public');
    header('Content-Length: ' . (filesize('installer.bin')+$sizehead+$sizefile+10000));
};

ob_end_flush();


for ($i=0;$i<count($filenevek);$i++)
    {readfile($filenevek[$i]);}

for ($i=0;$i<10;$i++)
  {                // 20*50=1000 char
   echo str_repeat('Stickman Warfare    ',50);
  }

?> 