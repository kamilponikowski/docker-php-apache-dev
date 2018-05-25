<?php
$conn = oci_connect('baza_bpsc', 'baza_bpsc', '192.168.6.20/BPSC');
if (!$conn) {
	$e = oci_error();
	trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
}

$stid = oci_parse($conn, 'SELECT indeks FROM indeksy WHERE rownum <= 5');
oci_execute($stid);

echo "INDEKSY: ";

while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
	echo " + ".$row['INDEKS'];
}

echo " + ";
echo PHP_EOL;