let
  azani-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGngaXa5FFAtueNUR/6le4LwnBoJkS9iHVVXNkpMHSY alex@zfc.io";
  azani-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX/519+M/iJif2Rz5Dziw4isdtElyal7hYPbibdcPg0 alex@zfc.io";

  keys = [
    azani-laptop
    azani-desktop
  ];
in
{
  "key.properties.age".publicKeys = keys;
  "upload-keystore.jks.age".publicKeys = keys;
}
