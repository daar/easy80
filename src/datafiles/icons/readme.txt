This folder contains all icons. The icons are drawn in SVG format. These files 
are automatically converted to 16x16 png files and some code is generated so 
they can be included in the IDE.

Drawing SVG icons
-----------------
When adding a new icon, please make sure to use inkscape. Do not use icons that
are licensed differently from the IDE.

Including icons in the IDE
--------------------------
Before compilation a tool called icons_update should be executed that will read 
the SVG files and convert them to .png. At the same time it will generate an 
include file with all appropriate icon constants together with a resource file 
and an include file that adds all icons to an image list. Therefore be careful 
to rename icons in the SVG file as the IDE might not compile.

Loading icons in Easy80-IDE
---------------------------
Loading an icon in the IDE is very simple. Simply use the file name without the 
extension e.g.

  Image1.Picture.LoadFromResourceName(HInstance,'ICON_EASY80');

If you would like to assign an icon index then you can use the defined variables

  TreeNode.ImageIndex := ICON_EASY80;

At start-up the IDE will load all icons into an image list by executing the 
following procedure:
 
  LoadFromResource(ImageList);
  
 By assigning this ImageList to components you will have access to all icons.