#!/bin/bash
#
#  Regent Products - "dog christmas" search images downloader
#  ---------------------------------------------------------------
#  Downloads the main product image for every product returned by
#  this search on regentproducts.com:
#
#    https://regentproducts.com/search.php?search_query=dog+christmas&section=product
#
#  HOW TO RUN (macOS)
#    Option A - double-click this file in Finder.
#               (If macOS refuses: right-click it, choose Open,
#                then click Open in the warning dialog.)
#    Option B - open Terminal and run:
#                 bash ~/Downloads/download_regent_dog_christmas.command
#
#  Images are saved into a folder named "Regent_Dog_Christmas",
#  created in the same place as this script.
#
#  Safe to re-run. Already-downloaded files are skipped, so if it is
#  interrupted or some images fail, just run it again.
#
#  Optional flags:
#    --jobs N      how many downloads to run at once (default 8)
#  ---------------------------------------------------------------

set -uo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1

OUT="Regent_Dog_Christmas"
JOBS=8

while [ $# -gt 0 ]; do
  case "$1" in
    --jobs)   shift; JOBS="${1:-8}" ;;
    -h|--help) sed -n '2,26p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

command -v curl >/dev/null 2>&1 || { echo "curl was not found on this Mac."; exit 1; }

# ---- the image list: filename<TAB>url, one per line -------------
image_list() {
cat <<'IMAGE_LIST_EOF'
69131P_DOG_TOY_CHRISTMAS_PLUSH_WREATH_4_ASSORTED_DESIGN_IN_PDQ_P32594.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16125/12137708/db1ec8fe-0c74-4588-9d28-7a6463e3dd0b_69131P%2520%2520%2520%2520%2520%2520%2520.__52569.1791366287.jpg?c=1
890486_DOG_TOY_CHRISTMAS_VINYL_SPORTS_BALL_5_ASSORTED_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27624/12144465/dec8a03b-fec7-41c7-a493-9c95fd4d5bd8_890486%2520%2520%2520%2520%2520%2520%2520.__35863.1791408162.jpg?c=1
66715P_DOG_TOY_CHRISTMAS_STOCKING_4PC_3_ASSORTED_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15845/12143628/fbcfb59e-0057-44ad-b8d4-321d93e9c003_66715P%2520%2520%2520%2520%2520%2520%2520.__70074.1791407096.jpg?c=1
69134P_DOG_TOY_CHRISTMAS_NYLON4_ASSORTED_DESIGN_IN_PDQ_P32596.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16131/12137711/a2be980b-27af-4328-9184-7435610dbd5d_69134P%2520%2520%2520%2520%2520%2520%2520.__83097.1791366290.jpg?c=1
68026P_DOG_TOY_CHRISTMAS_STOCKING-ROPEW-SQUEAKER_3_ASSORTED_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15988/12143650/dda27b34-c2e8-400b-9281-dc7a24739327_68026P%2520%2520%2520%2520%2520%2520%2520.__25284.1791407122.jpg?c=1
66708P_DOG_TOY_CHRISTMAS_ROPE_CHEWS_3_ASSORTED_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15840/12143626/4364ea6c-6159-4fa2-87be-841f26e55f63_66708P%2520%2520%2520%2520%2520%2520%2520.__67299.1791407094.jpg?c=1
69130P_DOG_TOY_CHRISTMAS_PLUSH_STOCKING_3_ASSORTED_MERRY_CHRISTMAS_PRINT_P325.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16123/12137707/5c153df9-4b12-4f0f-a73f-d4a47d0faba3_69130P%2520%2520%2520%2520%2520%2520%2520.__94120.1791366286.jpg?c=1
69188P_CHRISTMAS_DOG_TOY_PLUSH_POLAR_BEAR_LARGE_IN_PDQ_P32737.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16179/12137748/3e015724-ffcd-4a3e-8d79-55c70d3ded05_69188P%2520%2520%2520%2520%2520%2520%2520.__27644.1791366329.jpg?c=1
68096P_DOG_TOY_CHRISTMAS_PLUSH_&_ROPE_4_STYLES_P32156_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16048/12137668/8364fb30-e78f-4005-a279-adf429ee2fe5_68096P%2520%2520%2520%2520%2520%2520%2520.__42785.1791366245.jpg?c=1
67022PN_DOG_TOY_CHRISTMAS_ROPE_TUG14_INCH_2_ASSORTED_IN_PDQ_C25341.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15952/12137603/92b654b5-233f-48ca-9703-adf3f6b3f535_67022PN%2520%2520%2520%2520%2520%2520.__90595.1791366176.jpg?c=1
69187P_DOG_TOY_CHRISTMAS_PLUSH_LARGE_RIDE_WITH_ME_3-ASSORTED_P33446_COUNTER_D.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16177/12137747/4fbc3744-9868-4298-bd4b-c2af6527c51a_69187P%2520%2520%2520%2520%2520%2520%2520.__94938.1791366328.jpg?c=1
66952P_DOG_TOY_CHRISTMAS_VINYL_FIRE_HYDRANT-ROPE_3_COLORS_IN_PDQ_14078.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15919/12143644/991e0f3c-bf66-4e9f-8d6e-3e1f6d4af69e_66952P%2520%2520%2520%2520%2520%2520%2520.__23202.1791407115.jpg?c=1
68098P_DOG_TOY_CHRISTMAS_CANVAS_BONE_7.5IN_4_ASSORTED_STYLES_P32195_COUNTER_D.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16050/12137670/8095f501-5e86-495a-8871-7c485e186573_68098P%2520%2520%2520%2520%2520%2520%2520.__12779.1791366247.jpg?c=1
68095P_DOG_TOY_CHRISTMAS_CANVAS_3_ASSORTED_REINDEER-SANTA-TREE_P32155_COUNTER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16047/12137667/ea4ebadf-090b-4634-9e82-315bac1d524d_68095P%2520%2520%2520%2520%2520%2520%2520.__20012.1791366244.jpg?c=1
69194P_DOG_TOY_CHRISTMAS_PLUSH_W-SQUEAKER_4_ASSORTED_STYLES_REF_P33786_COUNTE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27613/12097675/4fbef30a-d4a1-4a4f-91de-95928bc746b7_69194P%2520%2520%2520%2520%2520%2520%2520.__55664.1790976063.jpg?c=1
69192P_DOG_TOY_CHRISTMAS_VINYL_W-SQUEAKER_ASST_DESIGN_AND_COLORS_IN_PDQ_REF_S.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27611/12132925/2bff77cc-b95c-461c-ae1c-abaa5cde5246_69192P%2520%2520%2520%2520%2520%2520%2520.__02192.1791321588.jpg?c=1
66898P_DOG_TOY_CHRISTMAS_VINYL_WITH_SQUEAKER_2PC_6_ASST_IN_PDQ_IN_POLY_BAG-HE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15900/12137562/8d03e8bc-c9d6-44e6-89e3-2d00b458088d_66898P%2520%2520%2520%2520%2520%2520%2520.__14509.1791366132.jpg?c=1
68094P_DOG_TOY_CHRISTMAS_PLUSH_4_ASSORTED_CANDY_CANE-TREE-PENGUIN-STOCKING_P3.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16046/12143660/d639f3c8-f4e4-4c0e-8a3f-9daa15b724a8_68094P%2520%2520%2520%2520%2520%2520%2520.__34513.1791407134.jpg?c=1
68059P_DOG_TOY_CHRISTMAS_PLUSH_LIGHT-BULBS_W-SQUEAKER_7-IN_4_COLORS_P30945_CO.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16020/12137647/794be6b6-813f-4903-92dd-ee1d7cb23938_68059P%2520%2520%2520%2520%2520%2520%2520.__43862.1791366223.jpg?c=1
66912P_DOG_TOY_CHRISTMAS_ROPE_CHEWS_6_ASSORTED_STYLES_3_COLORS_HANG_TAG_C6601.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15904/12143640/64baa61a-ab3d-46d3-bfd4-412d96b25d91_66912P%2520%2520%2520%2520%2520%2520%2520.__88479.1791407111.jpg?c=1
66623PN_DOG_TOY_CHRISTMAS_SHU_VELVETEEN_W-SQUEAKER_3_SHAPES_RED-GREEN_HANG_TAG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15832/11903361/66623PN__18903.1788898459.jpg?c=1
66892P_DOG_TOY_CHRISTMAS_VINYL_4_ASST_DEER-SNOWMN-SANTA-PENGUIN_IN_PDQ_HANG_T.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15899/11591508/66892P__90039.1763047648.jpg?c=1
66915P_DOG_TOY_CHRISTMAS_ROPE_CHEWS_5_ASSORTED_ROPES_&_1_DISC_RED-GREEN_HANG_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15906/12137567/f55da232-2b86-48cd-9df7-da23187730ba_66915P%2520%2520%2520%2520%2520%2520%2520.__82254.1791366137.jpg?c=1
66770PN_DOG_TOY_CHRISTMAS_CHENILLE_BONE_W-PAW_PRINT_ICON_8IN_4_COLORS_W-SQUEAK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15872/12143635/41af1f3d-b456-40b7-9d43-3bd46f9d4279_66770PN%2520%2520%2520%2520%2520%2520.__78388.1791407105.jpg?c=1
G91649_FLORAL_PICK_CHRISTMAS_GREENERY_9IN_6AST_STYLES_IN_36PC_PDQ_CHRISTMAS_H.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23450/11718061/G91649__18951.1773865272.jpg?c=1
G91556_CHRISTMAS_TREE_36IN-3FT_GREEN_CANADA_PINE_70STEMS_ON_PLASTICBASE_CHRIS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23428/12144157/86bff7d4-db7a-457e-a0af-46d3efed65e7_G91556%2520%2520%2520%2520%2520%2520%2520.__81254.1791407758.jpg?c=1
5050_DOG_TREATS_DENTAL_TOOTHSTICKS_FOR_SMALL_DOGS_13_OZ_CHICKEN_MADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14370/10484282/5050__60221.1757021850.jpg?c=1
5052_DOG_TREATS_DENTAL_TOOTHSTICKS_FOR_SMALL_DOGS_13_OZ_MINT_MADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14380/12137065/0efb1020-45da-4d93-9ea0-6f9d7c06b439_5052%2520%2520%2520%2520%2520%2520%2520%2520%2520.__89894.1791365601.jpg?c=1
5054_DOG_TREATS_YUMMY_BONES_FOR_SMALL_DOGS_13_OZ_CHICKEN_MADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14384/9499286/5054__90881.1750884104.jpg?c=1
G91618_NECKLACE_BEAD_2PK_CHRISTMAS_W-3_JINGLE_BELLS_4AST_COLORS_CHRISTMAS_BAR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23445/11716959/G91618__93927.1769716775.jpg?c=1
B111875-45557_CHRISTMAS_BOOKS_A_DAY_IN_THE_LIFE_OF_SANTA_16_AND_CHRISTMAS_PAPERCRAFT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33892/11717022/B111875455575__83910.1770653895.jpg?c=1
5056_DOG_TREATS_YUMMY_BONES_FOR_SMALL_DOGS_13_OZ_PEANUT_BUTTER_MADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14387/12143578/0724852d-004e-412f-b302-6d61db2714a1_5056%2520%2520%2520%2520%2520%2520%2520%2520%2520.__60455.1791407035.jpg?c=1
5053_DOG_TREATS_DENTAL_TOOTHSTICKS_FOR_MEDIUM-LARGE_DOGS_13_OZ_MINT_MADE_IN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14383/12137066/848537bc-1e84-4323-b375-36d9e827cff6_5053%2520%2520%2520%2520%2520%2520%2520%2520%2520.__15647.1791365602.jpg?c=1
5051_DOG_TREAT_DENTAL_TOOTHSTICKS_CHICKEN_FLAVOR_13_OZ_FOR_MEDIUM_TO_LARGE_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14374/11903359/5051__55047.1788898347.jpg?c=1
G91858_PLACEMAT_ROUND_CHRISTMAS_SHINY_TINSEL_15IN_DIA_RED-GOLD-SILVER-GREEN_C.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23545/11718141/G91858__60947.1775164667.jpg?c=1
8026_CHRISTMAS_STORY_BOOKS_4_ASSORTED_TITLES.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17087/11717986/8026__46668.1773685407.jpg?c=1
61525_CHRISTMAS_POKE_IN_ART_FUN_KIT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34167/11719868/61525__14544.1782935813.jpg?c=1
91016_PITCHER_5L_3_ASSORTED_CHRISTMAS_PRINTS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27639/5060331/91016__28252.1724423334.jpg?c=1
5151_DOG_TREATS_DENTAL_ORAL_BONE_1.3_OZ_FOR_MEDIUM_DOGS_MINT_&_PARSLEY_COUN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14529/12137123/8b2b492b-d5f9-4d86-9ec1-c7bdb3e045ab_5151%2520%2520%2520%2520%2520%2520%2520%2520%2520.__08142.1791365665.jpg?c=1
G91805_ORNAMENT_MDF_6AST_CHRISTMAS_XMAS-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33796/11719586/G91805__64731.1780605008.jpg?c=1
CCR-2430PD_PLUSH_11IN_PRAIRIE_DOG_12.00.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/35021/11725104/CCR-2430PD__01004.1787089233.jpg?c=1
91042_PITCHER_2.2L_3_ASSORTED_CHRISTMAS_PRINTS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27641/12134679/72d1f1f4-f871-48ff-89a3-d5ad82298345_91042%2520%2520%2520%2520%2520%2520%2520%2520.__92844.1791342681.jpg?c=1
G91659_GARLAND_CHRISTMAS_HOLLY_BERRY_9FT-_2.74M.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30753/11718369/G91659__42225.1776890304.jpg?c=1
92728_WALL_SIGN_METAL_12X12_CHRISTMAS_BLESSING.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/36074/12145613/6ada7a0d-b795-413f-87c4-784753aee6a6_92728%2520%2520%2520%2520%2520%2520%2520%2520.__65090.1791409601.jpg?c=1
G91696_HEADBOPPER_CHRISTMAS_4_ASST_XMAS_BARBELL_HDR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30877/11719882/G91696__84003.1782939826.jpg?c=1
91041_CHRISTMAS_FOOD_SAVER_2.6L_4_ASSORTED_DESIGNS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27640/12144468/b9083d29-7702-4e9d-8a94-5eb4718811b7_91041%2520%2520%2520%2520%2520%2520%2520%2520.__23386.1791408166.jpg?c=1
68061_CAT_TOY_CHRISTMAS_4_STYLES_ON_MERCH_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16022/12137648/dde4d493-24b0-4cdc-86b0-b7a8f1da9ac2_68061%2520%2520%2520%2520%2520%2520%2520%2520.__33819.1791366224.jpg?c=1
G91531N_YARD_STAKE_CHRISTMAS_6ASST_METAL_24IN_-_HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30876/11903403/G91531N__97112.1788900379.jpg?c=1
1108_CHRISTMAS_PLAY_PADS_2_ASSORTED_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/31426/11719649/1108__12677.1781551300.jpg?c=1
HO61528_CHRISTMAS_FOAM_DECORATIONS_12_FOAM_SHAPES_TO_DECORATE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34168/11719814/HO61528__66921.1782319772.jpg?c=1
G91550_PINE_WREATH_GREEN_16IN-65TIPS_CHRISTMAS_HEADER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27377/12125759/7fcc01f1-1e55-4918-8f53-0d59bbbcddf9_G91550%2520%2520%2520%2520%2520%2520%2520.__74744.1791235555.jpg?c=1
91526_TABLETOP_DECOR_5AST_CHRISTMAS_TREE_FABRIC_8.7X4.9X14.2.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/36014/12135216/bc71712b-dde4-4005-aa85-4b61650e149c_91526%2520%2520%2520%2520%2520%2520%2520%2520.__65012.1791343318.jpg?c=1
92634-18_WALL_SIGN_3AST_CHRISTMAS_BLOCK_WOOD_9.41X1.5X4.13.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/36067/12135220/03068d67-27c9-456f-87b7-91f2ff1c58e9_92634-18%2520%2520%2520%2520%2520.__19911.1791343322.jpg?c=1
890790_CAT_TOY_CHRISTMAS_WAND_ASSORTED_DESIGNS_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27620/12144464/9a77f694-2382-4953-ae4c-62b52e0a7cc9_890790%2520%2520%2520%2520%2520%2520%2520.__41326.1791408161.jpg?c=1
G91598_NUTCRACKER_CHRISTMAS_WOOD_10IN_3ASST_XMAS_LABEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27471/11718161/G91598__19519.1775592511.jpg?c=1
G91621_NAPKIN_2PK_CHRISTMAS_16X16IN_3_AST_HT-JHOOK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30461/12144693/d889fd85-4627-4c08-8996-831052457ce9_G91621%2520%2520%2520%2520%2520%2520%2520.__42774.1791408449.jpg?c=1
G91301N_CUTOUT_JOINTED_54IN_H_CHRISTMAS_4_ASST_PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30887/9515365/G91301N__67404.1750958501.jpg?c=1
1813_DISNEY_CHRISTMAS_SEARCH_AND_FIND_2_ASSORTED_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/31428/12144804/d7ca375f-4b9c-4439-8d35-63ff62ed0b41_1813%2520%2520%2520%2520%2520%2520%2520%2520%2520.__16520.1791408587.jpg?c=1
890660_CAT_TOY_WITH_CATNIP_CHRISTMAS_3_ASSORTED_ON_CHAIN_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27623/12131427/2968c1b1-e267-4041-a4c0-42e4ac64f75d_890660%2520%2520%2520%2520%2520%2520%2520.__99607.1791299775.jpg?c=1
91012_CHRISTMAS_PASTRY_TRAY_3_AST_COLORS_WITH_LOCKING_COVER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27638/12134677/9e923b96-66cf-4638-a407-5f53a0212893_91012%2520%2520%2520%2520%2520%2520%2520%2520.__51691.1791342679.jpg?c=1
3658_TOOTSIE_ROLL_CHRISTMAS_BANK_5.7_OZ_IN_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34028/11717921/3658__55802.1772572106.jpg?c=1
G91823_HEADBAND_CHRISTMAS_4AST_TREE-ELVES_XMAS_HT-JHOOK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33825/11718121/G91823__46264.1774989337.jpg?c=1
G91099P_STICKER_BOOK_CHRISTMAS_5PG_80CT_4AST_IN_48PC_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33717/11718158/G91099P__14263.1775592240.jpg?c=1
62410_DOG_TREAT_MUNCHIE_PIGS-N-BLANKET_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/35325/12095925/c02d696a-b7f5-4bcb-800f-6bf6c3c131cf_62410%2520%2520%2520%2520%2520%2520%2520%2520.__47083.1790943030.jpg?c=1
B3120_DISNEY_CHRISTMAS_VARIETY_PUZZLES_2_ASSORTED_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/31427/11691444/82f6a5d5-0f17-4fed-a298-72565c767546_B3120__55042.1763638819.jpg?c=1
G91737P_BOTTLE_BAG_PAPER_14IN_CHRISTMAS_6AST_IN_48PC_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33220/11718062/G91737P__80888.1773865368.jpg?c=1
G91719_PILLOW_COVER_CHRISTMAS_17.75IN_4AST_PATTERNS_XMAS_HEADER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30983/12144781/803ff083-7946-4fc7-b6ff-3461e836f65f_G91719%2520%2520%2520%2520%2520%2520%2520.__79390.1791408556.jpg?c=1
G91256_GARLAND_TINSEL_50FT_CHRISTMAS_4ASST_COLORS_WRAPCARD-PEGGABLE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23175/11717818/G91256__90303.1771624150.jpg?c=1
G16281_FIDGET_TOY_SPRINGY_DOG_4ASST_BLSTR_CARDED.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/20151/12139336/0f713eea-1c06-4f30-b925-abbac11f5d41_G16281%2520%2520%2520%2520%2520%2520%2520.__22180.1791368044.jpg?c=1
G91128_WINDOW_CLING_CHRISTMAS_12_AST_4C_PRINT_XM_HEADER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23052/12144115/1fd25572-0233-4d7b-890d-27f2ed5cf606_G91128%2520%2520%2520%2520%2520%2520%2520.__65495.1791407705.jpg?c=1
G91736P_GIFT_BAG_PAPER_XL_CHRISTMAS_6AST_IN_36PC_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33219/11719584/G91736P__28159.1780604781.jpg?c=1
G91617_APRON_CHRISTMAS_PRINT_4_ASST_ADULT_SIZE_HT-JHOOK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30457/12144692/5942a604-d6e3-4235-83bf-eb258e25f1c8_G91617%2520%2520%2520%2520%2520%2520%2520.__93385.1791408447.jpg?c=1
59609N_CHRISTMAS_PEEPS_6CT_MARSHMALLOW_STOCKINGS_3_OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25392/12092311/270fffc2-a992-4841-bad8-c965bde71a40_59609N%2520%2520%2520%2520%2520%2520%2520.__74952.1790938493.jpg?c=1
G91824_HEADBAND_CHRISTMAS_CHARACTER_W-GLASSES_4AST_XM-HT_JHOOK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33826/11718399/G91824__64400.1777581934.jpg?c=1
8506_CHRISTMAS_DOTS_FESTIVE_FLAVORS_6_OZ_BOX_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25404/5060274/8506__33544.1724422656.jpg?c=1
B3125_CHRISTMAS_STICKER_PUZZLES_2_ASSORTED_IN_3_CELL_FLOOR_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33893/11717021/B3125__88890.1770653866.jpg?c=1
66714P_CAT_TOY_CHRISTMAS_STOCKING_6PC_3_ASSORTED_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15844/12143627/43103bc0-cb5e-4041-8ce7-47c4537a5761_66714P%2520%2520%2520%2520%2520%2520%2520.__59292.1791407095.jpg?c=1
G91913_SANDWICH_BAGS_CHRISTMAS_PRINT_15CT_6.5X5IN_2_PRINTS-BOX.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23573/8330858/G91913__74890.1744404433.jpg?c=1
G91779_CHRISTMAS_TABLETOP_DECOR_SNOW-NOEL-JOY_W-BELL.MDF-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33757/11718063/G91779__28480.1773865453.jpg?c=1
67024_CAT_TOY_CHRISTMAS_ASSORTMENT_6_STYLES_CT10351_ON_MERCH_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15954/12137605/2dba031f-c1f6-4229-84ab-0a5309b59cdd_67024%2520%2520%2520%2520%2520%2520%2520%2520.__29010.1791366178.jpg?c=1
59601N_CHRISTMAS_PEEPS_3CT_MARSHMALLOW_SNOWMEN_1.5_OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25389/12144264/09ea6e7c-650c-416b-90ff-15143f576477_59601N%2520%2520%2520%2520%2520%2520%2520.__19312.1791407905.jpg?c=1
G91512_GEL_CLING_STICKERS_CHRISTMAS_8AST_DESIGNS_W-PRTD_BACKER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23409/12144155/603e54b1-c97f-4d62-b029-00c332816a31_G91512%2520%2520%2520%2520%2520%2520%2520.__41429.1791407756.jpg?c=1
3659_TOOTSIE_ROLL_CHRISTMAS_FRUIT_BANK_5.7_OZ_IN_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34029/11717922/3659__85504.1772572173.jpg?c=1
1152_NIGHTMARE_BEFORE_CHRISTMAS_2_ASST_VARIETY_PUZZLE_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/35217/12123318/041fcd74-6193-4e9f-94af-d07573d9fbbd_1152%2520%2520%2520%2520%2520%2520%2520%2520%2520.__42112.1791201706.jpg?c=1
59604N_CHRISTMAS_PEEPS_3CT_MARSHMALLOW_STOCKINGS_1.5_OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25387/12144263/50aae1f1-64e3-4246-a400-a55c8ae6abf4_59604N%2520%2520%2520%2520%2520%2520%2520.__96834.1791407903.jpg?c=1
890240_CAT_TOY_CHRISTMAS_DANGLER_WAND_6_ASSORTED_STYLES_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27617/12144462/470c2880-641d-4c42-ac3d-36977d9a8423_890240%2520%2520%2520%2520%2520%2520%2520.__06925.1791408158.jpg?c=1
59600N_CHRISTMAS_PEEPS_3CT_MARSHMALLOW_TREES_1.5_OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25390/12144265/7f3d18be-7717-48d3-9bb8-638863427720_59600N%2520%2520%2520%2520%2520%2520%2520.__97197.1791407906.jpg?c=1
G91732_DUCK_CHRISTMAS_NOVELTY_PVC_4AST_APROX_3X3.4X2.9IN-24PC_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33211/12144985/22e5b20d-3f46-4582-8c6c-fd4e2653e02c_G91732%2520%2520%2520%2520%2520%2520%2520.__49528.1791408823.jpg?c=1
G91733_PLATTER_OVAL_18.5IN_PLASTIC_4AST_CHRISTMAS_PRINTS_UPC_LABEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33200/11386180/e2f560cb-1121-4d15-8548-701eb6781eba_G91733__24185.1761924342.jpg?c=1
69133_CAT_TOY_CHRISTMAS_ASSORTMENT_6_STYLES_IN_MERCH_DISPLAY_CT11624.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16128/12137709/5a981691-4b56-48c7-bc5c-36c880dfb135_69133%2520%2520%2520%2520%2520%2520%2520%2520.__20821.1791366288.jpg?c=1
G91765_CANDY_APOTHECARY_JAR_4AST_CHRISTMAS_PRINTS_6X4IN_PLASTIC-LABEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33726/11713372/G91765__21263.1767738939.jpg?c=1
890325_DOG_TOY_TPR_BALL_SMALL_6_ASSORTED_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27648/12144472/4783b316-4d6d-4d75-9406-8ca6167ac58a_890325%2520%2520%2520%2520%2520%2520%2520.__23019.1791408171.jpg?c=1
91708_TABLETOP_SIGN_2AST_NOEL-JOY_CHRISTMAS_WOOD-METAL_6.75X2.4X6.75.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/36020/12135218/5dc223f3-881f-488a-a297-184b98adf9a6_91708%2520%2520%2520%2520%2520%2520%2520%2520.__37169.1791343320.jpg?c=1
CV6780_WOOD_BLOCK_SIGN_2_ASST_DOG_CATPP_5.99.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/18631/12138642/ae324bb1-1874-458e-a0ae-d3822fbf9473_CV6780%2520%2520%2520%2520%2520%2520%2520.__02675.1791367288.jpg?c=1
69118P_DOG_SEAT_BELT_ADJUSTABLE_BLACK_24_INCH_LENGTH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16117/12137703/83a3a863-d309-4f3b-b9ce-48e24b66fa42_69118P%2520%2520%2520%2520%2520%2520%2520.__32714.1791366282.jpg?c=1
PPT10003_DOG_TOY_WITH_SQUEAKER_JUMBO_PLUSH_4_ASSORTED_ANIMALS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34687/11719548/PPT10003__88650.1780412503.jpg?c=1
5130_DOG_TREATS_PUFFSTERS_CHIPSCRANBERRY_&_CHICKEN_4_OZMADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14518/12137119/a3df283f-05d9-4178-b87a-63a5d5ec57e5_5130%2520%2520%2520%2520%2520%2520%2520%2520%2520.__51989.1791365661.jpg?c=1
70504_DOG_TREATS_2PC_6_INCH_PORK_RAWHIDE_CHEW_RESEALABLE_BAG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16300/12137788/60bb244d-2c62-4c31-9851-10edf6c79650_70504%2520%2520%2520%2520%2520%2520%2520%2520.__07613.1791366373.jpg?c=1
60022_DOG_TREAT_MUNCHIE_2CT_CHOP_&_BONE_PDQ_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/35326/12145576/d9779b85-ef60-4348-9f68-3e5406ccaafa_60022%2520%2520%2520%2520%2520%2520%2520%2520.__94270.1791409557.jpg?c=1
3534N_BLOW_POP_MINIS_CHRISTMAS_THEATER_BOX_3_OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25455/12144271/83dec623-0c2f-4ad5-b353-89a475dea546_3534N%2520%2520%2520%2520%2520%2520%2520%2520.__43415.1791407914.jpg?c=1
G91699_CHRISTMAS_TREE_17.7IN_41_TIPS_TINSEL_GREEN_OR_WHITE_COLOR_BOXED.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30879/12126131/d29bf6bf-4d8d-4ad1-9ae9-0814d4410c1f_G91699%2520%2520%2520%2520%2520%2520%2520.__13357.1791236037.jpg?c=1
59608N_CHRISTMAS_PEEPS_6CT_MARSHMALLOW_GINGERBREAD_MEN_3_OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25391/12092310/e6ae6ace-79d4-44c6-962e-568b51fa9c7c_59608N%2520%2520%2520%2520%2520%2520%2520.__44790.1790938492.jpg?c=1
G91315T_DOOR_COVER_CHRISTMAS_30X60_IN_4AST_DESIGNS_PB-INSERT_NO_AMAZON_SALES.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23232/11717029/G91315T__31522.1770667229.jpg?c=1
69253_DOG_MAT_13_X_19_NON-SLIP_RANDOM_COLORS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/31606/12144826/f6b87ee7-a78b-4161-8c67-69988f0e276d_69253%2520%2520%2520%2520%2520%2520%2520%2520.__09437.1791408613.jpg?c=1
G91093N_PAIL_METAL_CHRISTMAS_4_AST-_4IN_W-_HANDLE_XMAS_LABEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30719/12144714/a762287d-1503-4cea-8113-e6e71292cf9d_G91093N%2520%2520%2520%2520%2520%2520.__15735.1791408476.jpg?c=1
G91112T_TREAT_BOX_6PK_CHRISTMAS_3X3_IN_PAPER_6AST_DESIGNS-XMAS_PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23034/11716984/G91112T__36755.1770320899.jpg?c=1
G91076_CUTOUT_JOINTED_FELT_CHRISTMAS_FIGURES_4AST_APROX_20IN_EA-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33857/11718190/G91076__69128.1775748652.jpg?c=1
G91116T_CHRISTMAS_ELF_REPORTS_AND_POST_BOX_STATIONARY_SET_25PK_XMAS_HEADER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23040/11718132/G91116T__65458.1775164074.jpg?c=1
PPT10001_DOG_TOY_WITH_SQUEAKER_24_INCH_JUMBO_ICE_CREAM_CONE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34686/11719547/PPT10001__36733.1780412444.jpg?c=1
59603N_CHRISTMAS_PEEPS_3CT_MARSHMALLOW_GINGERBREAD_MEN_1.5_OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25388/12125574/9572e104-e8de-4de5-9f6a-25d458b3746a_59603N%2520%2520%2520%2520%2520%2520%2520.__14204.1791235305.jpg?c=1
G91775_WALL_PLAQUE_CHRISTMAS_TIN_8X10IN_3AST_W-LABEL_IN_24PC_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33749/11717785/G91775__87461.1771446371.jpg?c=1
G91637_PIE_MOLD_CHRISTMAS_3_ASST_STAR-_GLOVE-_TREE_XMAS_PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30743/12097934/2d1b6647-b2fe-4f63-b786-65fe079ec5df_G91637%2520%2520%2520%2520%2520%2520%2520.__28744.1790976388.jpg?c=1
8004_DOG_TREATS_2_OZ_SWEET_POTATO_&_DUCK_RECIPE_STICKS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17063/7262615/8004__55148.1738341174.jpg?c=1
G91318_SANTA_HAT_RED_VELVET_PLUSH_CUFF_15X12IN_CHRISTMAS_HT-JHOOK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23236/11718112/G91318__82979.1774988594.jpg?c=1
G91777_2-TIER_CHRISTMAS_TRAY_DECOR_6AST_STYLES_MDF_IN_24PC_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33758/11716990/G91777__55025.1770321386.jpg?c=1
68057P_DOG_TOY_PLUSH_W-SQUEAKER_CUPCAKE_&_PRESENT_IN_PDQ_P30956.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16018/12143656/d6201698-4241-4509-822b-57e821f326d4_68057P%2520%2520%2520%2520%2520%2520%2520.__45918.1791407129.jpg?c=1
91415T_SERVING_TRAY_CHRISTMAS_13_INCH_ROUND_4_ASSORTED_DESIGNS_169G.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25071/12144250/a7f9bcd0-0fae-46a2-ac13-f7f2e7bc32a9_91415T%2520%2520%2520%2520%2520%2520%2520.__27319.1791407887.jpg?c=1
G91567_ORNAMENT_SHAPE_CHRISTMAS_TIN_3AST_DESIGNS_W-STRING_XMAS-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27312/12144416/2a0aeb33-734d-4518-a3df-ddde6434d97b_G91567%2520%2520%2520%2520%2520%2520%2520.__13482.1791408099.jpg?c=1
G91845_CHRISTMAS_SQUEEZE_STRESS_CHARACTERS_SANTA-TREE-REINDEER-SNOWMAN_IN_12P.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33838/11719588/G91845__46133.1780605144.jpg?c=1
G91693_WALL_STICKERS_CHRISTMAS_DECORATIVE_FOIL_4AST-_2PKS_14X11IN-_PBH-_INSER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30890/11718164/G91693__42301.1775592775.jpg?c=1
68108P_DOG_TOY_PLUSH_4_ASST_TIKI_DRINKS_IN_PDQ_P31757.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16060/12137680/7a2bbdd9-33ae-4a21-995c-5ae80f5dc22a_68108P%2520%2520%2520%2520%2520%2520%2520.__42607.1791366258.jpg?c=1
67023P_CAT_TOY_CHRISTMAS_WITH_BELLS_4PC_PVC_TUBE_CT10064_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15953/12143649/1597a38f-351a-4fd5-a3d9-a4ae92251414_67023P%2520%2520%2520%2520%2520%2520%2520.__46061.1791407121.jpg?c=1
G91058PCS_BAKING_CUPS_CHRISTMAS_2IN_50CT_4AST_ON_12PC_PRELOADED_MDSGSTRIP-PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33736/11718157/G91058PCS__12362.1775592174.jpg?c=1
G91263N_GIFT_TAG_BOOK_CHRISTMAS_48PC-52PC_3AST-IN_TRAY_DISPLAY_UPC.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30736/11718377/G91263N__41735.1777062523.jpg?c=1
G91829T_GIFT_BAG_BIKE_60X72IN_PLASTIC_3AST_CHRISTMAS_DESIGN_PB-INSERT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23526/11718064/G91829T__48596.1773865545.jpg?c=1
G91528T_BOW_RED_VELVET_2PK_5LOOP_9IN_X_16IN_CHRISTMAS_TCD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23423/12144156/9fb2e090-ffc6-42f4-8d1d-c4a196424d67_G91528T%2520%2520%2520%2520%2520%2520.__88925.1791407757.jpg?c=1
66925P_DOG_TOY_VINYL_BONE_WITH_SQUEAKER6_ASSORTED_COLORS_IN_PDQ_14038.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15911/12143641/d3329bcb-1efa-452a-9297-4a4f178741b2_66925P%2520%2520%2520%2520%2520%2520%2520.__48935.1791407112.jpg?c=1
60550_DOG_TREATS_5_INCH_WHITECURL_RAWHIDE_CHEW_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15432/12143616/f377034c-d640-4b4b-9d38-2e67ac970e67_60550%2520%2520%2520%2520%2520%2520%2520%2520.__45574.1791407082.jpg?c=1
890226_CAT_TOY_CHRISTMAS_LATTICE_BALLS_4PK_ASSORTED_ON_CHAIN_MERCH_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27618/12144463/34f88870-e2b5-4807-aeca-f62b6efcd9b0_890226%2520%2520%2520%2520%2520%2520%2520.__18639.1791408159.jpg?c=1
69142P_DOG_TOY_VINYL_ANIMALS_ASSORTEDCOLORS_HANH_TAG_IN_PDQS20919.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16139/12143664/c7b11078-2fcb-4add-a043-a23d77f41350_69142P%2520%2520%2520%2520%2520%2520%2520.__74317.1791407139.jpg?c=1
G91783_CHRISTMAS_TINSEL_TREE_12IN_5AST_COLORS-32_TIPS_W-CEMENT_BASE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33763/11719855/G91783__69808.1782502465.jpg?c=1
G91297_BOW_RED_VELVET_11.5W_X_26IN_L_10-LOOP_CHRISTMAS_TCD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23215/11718216/G91297__75830.1775762299.jpg?c=1
69101_DOG_MAT_NON-SLIP_4_ASSORTED_STYLES_13_X_19.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16101/12137693/7a1d4184-65e8-43e0-8df4-e76f373bcc88_69101%2520%2520%2520%2520%2520%2520%2520%2520.__37207.1791366272.jpg?c=1
G91627_KITCHEN_SPONGES_CHRISTMAS_SHAPES_3_LAYER-_4_STYLES-_20PC_PDQ-_HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30721/12144716/ea059403-6deb-41c3-a77e-7a06813849e2_G91627%2520%2520%2520%2520%2520%2520%2520.__02027.1791408479.jpg?c=1
G91591N_CHRISTMAS_TREE_TOPPER_BOW_6_ASST_11_X_31IN_TCD-NOPROP65.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30744/12144727/9bfdf24b-0d45-42fe-acd9-846ce38f3cf8_G91591N%2520%2520%2520%2520%2520%2520.__43590.1791408492.jpg?c=1
G91768_SERVING_TRAY_DIVIDED_6_SECTION_2AST_CHRISTMAS_PRINTS-PLASTIC_XMAS-LABE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33756/11719276/G91768__44567.1779222887.jpg?c=1
G91224T_TABLECOVER_COLOR_YOUR_OWN_PAPER_CHRISTMAS_36X48IN_INSERT_CARD_W-PB.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23147/11718134/G91224T__91577.1775164208.jpg?c=1
G91789M_CHRISTMAS_TINSEL_TREE_CONE_10IN_4_ASST_CLRS-MATTE_XMAS_HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30875/11717825/G91789M__44331.1771624696.jpg?c=1
50233_PEZ_CHRISTMAS_DISPENSER-CANDY_FLOOR_DISPLAY_84_DISPENSERS_-_24_6PK_ROL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25464/12144273/b2c4bab7-8dfa-4141-b475-28c62db478f1_50233%2520%2520%2520%2520%2520%2520%2520%2520.__71172.1791407916.jpg?c=1
G91690_WINDOW_DECOR_CHRISTMAS_CLEAR_W-_SUCTION_CUP_11.75_x_16.5IN_-_PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30889/11718163/G91690__85676.1775592672.jpg?c=1
B3114P_WORD_FIND_CHRISTMAS_2_ASST_LG_PRINT_OR_REGULAR_IN_PDQ_PPD_3.95.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/18096/11715002/91397227-a797-4130-b7ee-a19654714df0_B3114P%2520%2520%2520%2520%2520%2520%2520.__87592.1768212472.jpg?c=1
G91561_WALL_PLAQUES_CHRISTMAS_WITH_REVERSABLE_FUN_SAYINGS_5AST_W-RIBBON_XMAS-.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27353/12144420/8d5982d4-9862-4542-862d-bf4d19106799_G91561%2520%2520%2520%2520%2520%2520%2520.__34304.1791408104.jpg?c=1
G91751_GIFT_TAGS_CHRISTMAS_6CT_W-JINGLE_BELL-SELF_ADHESIVE_PB_INSERT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33700/11717823/G91751__34639.1771624562.jpg?c=1
G91702M_CHRISTMAS_TREE_MATTE_TINSEL_24IN-50TIPS_3_FASHION_COLOR_XMASHT-PB.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33762/11716840/G91702M__47890.1768597350.jpg?c=1
5110_DOG_TREATS_PUFFSTERS_CHIPS_BANANA_&_CHICKEN_4_OZ_MADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14504/12143583/6dca6158-d5c2-48b5-a00a-1c48f3e13962_5110%2520%2520%2520%2520%2520%2520%2520%2520%2520.__41077.1791407040.jpg?c=1
G91548_TINSEL_GARLAND_9FT_3PLY_CHRISTMAS_BUFFALO_PLAID_4_AST_3IN_TIPS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27388/12144424/af0b029d-d220-410e-904a-d60a81f056af_G91548%2520%2520%2520%2520%2520%2520%2520.__12155.1791408110.jpg?c=1
G91330_TABLE_DECOR_CHRISTMAS_4AST_MDF_W-GREENERY_&_PINECONE_UPC-COMPLY_LABEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23247/12144135/4e862c94-ad4c-4c64-ac54-3c2ff174229d_G91330%2520%2520%2520%2520%2520%2520%2520.__83791.1791407730.jpg?c=1
5662_DOG_TREATS_PURE_BUFFALO_4_OZ_LUNG_STEAK_RESEALABLE_ZIPER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15037/12143602/879e475e-524c-48d5-9d86-f4bccdb63c90_5662%2520%2520%2520%2520%2520%2520%2520%2520%2520.__25376.1791407061.jpg?c=1
G91735P_GIFT_BAG_PAPER_LG_CHRISTMAS_6AST_IN_36PC_PDQ_10.2x12.75x5IN_MATTE_FINI.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33218/12144990/396726d1-8a56-4bc7-b1a3-bc784d456f21_G91735P%2520%2520%2520%2520%2520%2520.__16041.1791408829.jpg?c=1
G91822N_BOW_CHRISTMAS_9AST_WOODLAND_SINGLE-2-3PKS_BURLAP-BUFFALO_XMAS_TCD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23521/12119753/aef283ac-7b57-44b3-ad03-20f412619009_G91822N%2520%2520%2520%2520%2520%2520.__99721.1791197372.jpg?c=1
G91034M_GIFT_BAG_GIANT_CHRISTMAS_24x4x18_4_ASST_HORIZ_&_VERT_UPC_LABEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30954/11717322/G91034M__71233.1771274579.jpg?c=1
1803_COLORING_BOOK_ADULT_CHRISTMAS_DESIGNER_SERIES_3_ASSTD_IN_48PC_COUNTER_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/10500/11719650/1803__42393.1781551383.jpg?c=1
890110_DOG_TOY_FLYING_DISK_6-ASSORTED_COLORS_7-IN_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27646/12026035/f6e4db5b-d334-4ed0-873d-c5c3638f0b80_890110%2520%2520%2520%2520%2520%2520%2520.__90075.1790198580.jpg?c=1
14432279-BG25_BOWS_CHRISTMAS_25CT_PEEL_N_STICK_AST_COLORS_PRINTED_POLY_BAG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33650/11718298/14432279-BG25__36834.1776284933.jpg?c=1
8011_DOG_TREATS_10PK_3_OZ_DENTAL_STICKS_CHICKEN_MADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17073/12138057/884e859a-0156-4765-a915-576842c77c30_8011%2520%2520%2520%2520%2520%2520%2520%2520%2520.__39384.1791366666.jpg?c=1
69207P_DOG_TOY_PLUSH_WITH_SQUEAKER_9_INCH_ICE_CREAM_CONE_ASSORTMENT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27671/12144477/373d0625-f97e-4187-b9ee-a8f1688f608c_69207P%2520%2520%2520%2520%2520%2520%2520.__11710.1791408177.jpg?c=1
G91825_CHRISTMAS_BALLPOINT_PEN_W-4_NOVELTY_POMPOM_CHARACTERS_24PC_PDQ-LABEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33828/11718295/G91825__03421.1776199276.jpg?c=1
91436_WALL_SIGN_3AST_CHRISTMAS_PEACE-SILENT_NIGHT-ALL_IS_BRIGHT_METAL_9.88X0.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/36011/12134032/da9e049f-52a8-4cf0-94bd-a956f2f437c4_91436%2520%2520%2520%2520%2520%2520%2520%2520.__59172.1791322933.jpg?c=1
G91597_TABLE_DISPLAY_ROUND_FOOTED_MDF_CHRISTMAS_DESIGNS_7.8IN_DIA_2_ASST.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27477/11716988/G91597__99189.1770321239.jpg?c=1
66928P_DOG_TOY_VINYL_SOLAR_BALL_WITH_SQUEAKER_6_COLORS_IN_PDQ_14041E.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15913/12137573/4603b564-611d-4776-aeeb-3bcd7f368f1b_66928P%2520%2520%2520%2520%2520%2520%2520.__59106.1791366144.jpg?c=1
66985PN_DOG_TOY_SPORTS_BALL_2.5_INCH_DIA_4_ASSORTED_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15934/12143647/0ca596c1-50a3-44e2-8b29-bd087d837563_66985PN%2520%2520%2520%2520%2520%2520.__92351.1791407118.jpg?c=1
69238P_DOG_TOY_VINYL_JUICE_DRINKS_4_ASSORTED_IN_PDQ_REF_408998.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30930/11708609/69238P__55051.1766094069.jpg?c=1
G89973_ANIMAL_SKELETON_SITTING_DOG_7.2IN_-_SITTING_KITTY_8.2IN_HLWN_HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30571/11718110/G89973__48503.1774988433.jpg?c=1
G91610_CURLY_BOW_3PK_CHRISTMAS_TRI-COLOR_4AST_METALLIC_COMBOS_XMAS_TCD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27637/11718346/G91610__95072.1776873989.jpg?c=1
EE001_EVERGREEN_ELF_CHRISTMAS_TREE_WATER_SENSOR_FITS_ALL_TREE_STANDS_19.99.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/31077/12086155/b96ed9d7-0266-49fc-9784-77e23ded6c28_EE001%2520%2520%2520%2520%2520%2520%2520%2520.__94267.1790910611.jpg?c=1
8230_GIFT_BOX_3PK_LINGERIE_CHRISTMAS_11_X_8_X_1.25_RANDOM_ASSORTED.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27527/12144459/46c684ff-4496-4725-b274-54106d7d9efb_8230%2520%2520%2520%2520%2520%2520%2520%2520%2520.__70229.1791408154.jpg?c=1
W88760GR_ALUMINUM_ROASTERS-BAKING_PANS_RED-GREEN_60CT_CHRISTMAS_DISPLAY_MADE_IN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/24812/11713368/W88760GR__89169.1767738663.jpg?c=1
68036P_DOG_TOY_PLUSH_7IN_SLIPPER_WITH_SQUEAKER_4_COLORS_IN_PDQ_P30932.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15998/12143652/7db92456-52f4-4667-a00b-c95113c627a0_68036P%2520%2520%2520%2520%2520%2520%2520.__66647.1791407124.jpg?c=1
G91308_GARLAND_TINSEL_CHRISTMAS_9FT_2-TONE_6AST_COLORS_XMAS_BARBELL_HDR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23225/11717800/G91308__74574.1771526824.jpg?c=1
70504_DOG_TREATS_2PC_6_INCH_PORK_RAWHIDE_CHEW_RESEALABLE_BAG_2.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16300/12137788/60bb244d-2c62-4c31-9851-10edf6c79650_70504%2520%2520%2520%2520%2520%2520%2520%2520.__07613.1791366373.jpg?c=1
14432279_BOWS_CHRISTMAS_25CT_PEEL_N_STICK_ASSORTED_COLORS_PRINTED_POLY_BAG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27847/12144482/04cbc4d9-3ecd-4463-96e3-fc365e47f19d_14432279%2520%2520%2520%2520%2520.__10011.1791408183.jpg?c=1
5663_DOG_TREATS_8_OZ_LUNG_STEAKS_RESEALABLE_ZIPPER_PEG_BAG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26909/12144395/93a28dbe-6ea2-4a6c-828a-566e2e955a48_5663%2520%2520%2520%2520%2520%2520%2520%2520%2520.__99861.1791408072.jpg?c=1
68027P_DOG_TOY_VINYL_4_ANIMAL_ASSORT_W-ROPE_&_SQUEAKERS20403.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15989/9499333/68027P__33054.1750885311.jpg?c=1
69211P_DOG_TOY_VINYL_WITH_SQUEAKER_2PK_VEGGIE_ASSORTMENT_IN_PDQ_REF_S21463.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27837/12144480/de46de16-f8ef-4dd2-9f4d-bcef4213e2ef_69211P%2520%2520%2520%2520%2520%2520%2520.__50065.1791408180.jpg?c=1
755516_SPATULA_18PK_PDQ_3AST_CHRISTMAS_OH_WHAT_FUN_ASSORTED_SILICONE-WOOD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34049/11717930/755516__65778.1772573224.jpg?c=1
G91784_CHRISTMAS_TINSEL_TREE_18IN_5AST_COLORS_W-32_TIPS-CEMENT_BASE-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33764/11719856/G91784__12012.1782502552.jpg?c=1
61527_CHRISTMAS_FOIL_IT_FUN_CRAFT_ACTIVITY_SET_OVER_100_3D_FOAM_STICKERS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34938/12144836/b4444823-a1d0-4430-8aa2-b0fe6b3cffb6_61527%2520%2520%2520%2520%2520%2520%2520%2520.__68732.1791408625.jpg?c=1
68030P_DOG_TOY_ROPE_WITH_RUBBER_CHEW_ASSORTMENT_PINK_AND_GRAY_IN_PDQ_C25644.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15992/11719911/68030P__04025.1783528828.jpg?c=1
69148P_DOG_TOY_PLUSH_HALLOWEEN_SKELETON3_ASSORTED_HANG_TAG_IN_PDQP32602.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16145/12137725/5f93b981-febe-4eb9-8403-2e077c460288_69148P%2520%2520%2520%2520%2520%2520%2520.__75879.1791366304.jpg?c=1
66869PN_DOG_TOY_PLUSH_8_INCH_BONE_WITHSQUEAKER_ANIMAL_PRINTS_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15893/12137558/98c16961-7338-419b-a050-bba061b19488_66869PN%2520%2520%2520%2520%2520%2520.__93692.1791366127.jpg?c=1
G91385_GNOME_CHRISTMAS_TABLE_DECOR_4AST_4.5X8.75IN_W-ARMS_WEIGHTED_BOTTOMS_XM.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23303/11716901/G91385__20831.1769460569.jpg?c=1
8234_GIFT_BOX_CHRISTMAS_3PK_12_X_5_X_3_RANDOM_ASSORTED_DESIGNS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30666/12143715/7ad6c48a-bd04-4ce3-a7a7-42e7be288bae_8234%2520%2520%2520%2520%2520%2520%2520%2520%2520.__68930.1791407204.jpg?c=1
G91471_CANDY_CANES_PLASTIC_ORNAMENTS_3-4-8PC_EA_IN_2AST_COLORS_CHRISTMAS_PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23373/11718135/G91471__56587.1775164265.jpg?c=1
G91419_HEADBAND_CHRISTMAS_3_FUNCTION_LIGHT-UP_3AST_BULB-CANDY-SNOWFLAKE_EA-HD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/24858/11708326/bf896e80-7ef6-4a00-89f8-6a2bf3c13003_G91419%2520%2520%2520%2520%2520%2520%2520.__26982.1765793140.jpg?c=1
69138P_DOG_TOY_PLUSH_BOTTLE_ASST_COLOR_SHANG_TAG_IN_PDQ_P32578.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16135/12143662/06d81936-be38-4804-8589-fe6993d54b9a_69138P%2520%2520%2520%2520%2520%2520%2520.__29143.1791407137.jpg?c=1
G91588_STOCKING_18IN_LIGHT_UP_4AST_3D_CHRISTMAS_ICONS_W-TINSEL_JHOOK-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27456/9515372/G91588__22024.1750959074.jpg?c=1
G91675_TABLE_DECOR_CHRISTMAS_HORIZONTAL_18IN_MDF_4_AST_STYLES-_XMAS-_MDF_LABE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30851/12144736/1bd9f59f-2e40-449e-a657-6d751fe0fa9b_G91675%2520%2520%2520%2520%2520%2520%2520.__60258.1791408502.jpg?c=1
G91680_CRAFT_KIT_PAINT_SET_W-_BOARD_&_EASEL_CHRISTMAS_4_ASST_DESIGNS_BLC.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30868/11708311/b679b2da-b36c-40ba-8569-500adec27d35_G91680%2520%2520%2520%2520%2520%2520%2520.__70302.1765793123.jpg?c=1
HA222_GIFT_BAG_CHRISTMAS_3_SIZE_W-SPINNER_96_LG_72_MED_48_XL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23749/12119857/d1f2a366-cff7-43fc-b962-bd95ba02fbe9_HA222%2520%2520%2520%2520%2520%2520%2520%2520.__26964.1791197493.jpg?c=1
G91808_BELL_DOORKNOB_HANGER-ORNAMENT_CHRISTMAS_DECOR_7IN_4AST_W-GREENERY_XMAS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33802/11719283/G91808__14456.1779223472.jpg?c=1
G91728_COOKIE_CONTAINER_SQUARE_CHRISTMAS_PRINT_W-LID_3AST_PLASTIC_10X10X2.55I.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33198/11678710/d531bf55-81b8-4d55-b2fe-e215546ba028_G91728__50751.1763557212.jpg?c=1
8223_GIFT_BAG_XL_CHRISTMAS_4_ASSORTED_13_X_18_X_5_WHIMSICAL_CHARACTERS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27520/12144455/0a549bbd-6101-4490-a22c-9c888ab3c300_8223%2520%2520%2520%2520%2520%2520%2520%2520%2520.__86411.1791408149.jpg?c=1
8226_GIFT_BAG_XL_CHRISTMAS_4_ASSORTED_13_X_18_X_5_CHARACTER_FACE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27523/12144457/4b2ffe50-f6dd-47fa-b502-0dcd9dfed659_8226%2520%2520%2520%2520%2520%2520%2520%2520%2520.__51151.1791408151.jpg?c=1
G91120T_GIFT_TAGS_18CT_CHRISTMAS_2_ASTPOP-OUT_HOTSTAMP_SELF-ADHESIVE-XMAS_PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23043/11718133/G91120T__17289.1775164136.jpg?c=1
5120_DOG_TREATS_PUFFSTERS_CHIPS_SWEET_POTATO_&_CHICKEN_4_OZ_MADE_IN_USA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14514/11705926/5120__88196.1764781196.jpg?c=1
8229_GIFT_BOX_2PK_SHIRT_CHRISTMAS_14.25_X_9.43_X_1.87_RANDOM_ASSORTED.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27526/12144458/669e22ac-2257-4660-8c15-99fc80644d9d_8229%2520%2520%2520%2520%2520%2520%2520%2520%2520.__69742.1791408153.jpg?c=1
G91925M_GIFT_BAG_LARGE_CHRISTMAS_12_ASST_10_X_5_X_12.5_UPC_LAB.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30958/11717060/G91925M__53568.1771019205.jpg?c=1
G91411_HAT_CHRISTMAS_NOVELTY_4AST_2_TREE-ELF_LEGS-SANTA_HAT_HANGTAG-JHOOK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23321/11718394/G91411__29731.1777581544.jpg?c=1
G91513_SIPPER_BOTTLE_W-FLIPTOP_STRAW_16OZ_3AST_CHRISTMAS_PRINTS-UPC_TRAY_DISP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23411/11718481/G91513__59379.1778101744.jpg?c=1
G91796_ORNAMENTS_MINI_TREE_CHRISTMAS_BELLS_12PC_1.18IN_SILVER-RED-GOLD_XMAS_P.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33784/11718137/G91796__62580.1775164422.jpg?c=1
G91395CS_LOOT_BAG_CELLO_CHRISTMAS_15CT_4_ASSORTED_11X2.5X5IN_PBH_ON_24PC_MERCH_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23312/11718059/G91395CS__65042.1773865078.jpg?c=1
68040P_DOG_TOY_CANVAS_SPORTS_DUMBELL10IN_W-SQKR_ASST_COLORS_IN_PDQ_P30953.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16002/12143655/55250b46-fa80-4bef-b5e3-94dc200c47b6_68040P%2520%2520%2520%2520%2520%2520%2520.__50073.1791407128.jpg?c=1
G91740_GIFT_BAG_LARGE_CHRISTMAS_HOUSES_4AST_10X12.5X5IN_W-RIBBON_HANDLE_UPC_L.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33696/11717866/G91740__84173.1772051341.jpg?c=1
9100_GIFT_WRAP_CHRISTMAS_40SQ_FT_1.5IN_CORE_ASST_DESIGN_3.99_PRPCDMADE_IN_U.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17566/12144211/a0c40353-9a2d-4cc7-9cc4-2978707ecef1_9100%2520%2520%2520%2520%2520%2520%2520%2520%2520.__74429.1791407823.jpg?c=1
60036_DOG_TREATS_4-5_INCH_NATURAL_BONE_RAWHIDE_CHEW_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15343/12137360/b21f6187-70cb-488f-83a0-c2fa7228c523_60036%2520%2520%2520%2520%2520%2520%2520%2520.__45740.1791365923.jpg?c=1
68041P_DOG_TOY_PLUSH_DESSERT_ASSORTMENTWITH_SQUEAKER_6_STYLES_IN_PDQP30941+P3.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16003/11718389/68041P__56857.1777581105.jpg?c=1
68023P_DOG_TOY_CANVAS_W-SQUEAKER_PAWSHAPE_DESIGN_4_COLORS_IN_PDQ_P30200.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15985/12137617/f09ec57a-c7c9-4beb-8037-92c19873f44b_68023P%2520%2520%2520%2520%2520%2520%2520.__57274.1791366191.jpg?c=1
68046P_DOG_TOY_PLUSH-ELASTIC_BONE_10INW-SQUEAKER_4_ASSORTED_IN_PDQP30948.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16008/12137639/db672286-b40f-4b5c-a8af-edb069ca4922_68046P%2520%2520%2520%2520%2520%2520%2520.__00383.1791366214.jpg?c=1
69151P_DOG_TOY_HALLOWEEN_PLUSH_3-ASSORTED_HANG_TAG_P32604_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16149/12137727/b7af2945-6cd6-4981-afdb-fdafa599aaeb_69151P%2520%2520%2520%2520%2520%2520%2520.__88311.1791366307.jpg?c=1
G91818_BANNER_CHRISTMAS_2PC_SET_FRONT_PORCH-SIDE_LIGHT-ENTRYWAYS_4AST_12X71IN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33820/11718193/G91818__76717.1775748819.jpg?c=1
G91927M_GIFT_BAG_XL_CHRISTMAS_12_ASST_13_X_4_X_18IN_UPC_LAB.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30960/11717869/G91927M__97925.1772051561.jpg?c=1
8233_GIFT_BOX_CHRISTMAS_3PK_LINGERIE_KRAFT_11_X_8_X_1.25_RANDOM_ASSORTED.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17208/12143714/2cc2ba73-fd51-4160-aebf-3554914d5ca5_8233%2520%2520%2520%2520%2520%2520%2520%2520%2520.__71250.1791407203.jpg?c=1
8235_GIFT_BOX_CHRISTMAS_2PK_SQUARE_11_X_11_X_3_RANDOM_ASSORTED_DESIGNS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30667/12143716/b840ab5c-912e-4649-9422-3f93bfe690f7_8235%2520%2520%2520%2520%2520%2520%2520%2520%2520.__05413.1791407206.jpg?c=1
69239P_DOG_TOY_SQUEAKER_VINYL_WAFER_COOKIE_3_ASSORTED_IN_PDQ_REF_409100.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30949/11708600/69239P__65469.1766093468.jpg?c=1
91456F-96_COLOR-ACTIVITY_BOOK_CHRISTMAS_2_ASST_MADE_IN_USA_PPD_4.95_IN_FLOOR_DIS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17622/12089343/bf16a8fc-5f0f-4a16-b72d-21bd4e2722aa_91456F-96%2520%2520%2520%2520.__89618.1790935063.jpg?c=1
68101P_DOG_TOY_HALLOWEEN_CANVAS_BONE_7.5IN_4_ASSORTED_P30199_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16053/12137673/3b7da293-a5ce-4ee7-a63a-332d22dec332_68101P%2520%2520%2520%2520%2520%2520%2520.__03123.1791366251.jpg?c=1
G915240_PINECONE_ORNAMENT_2PK_4AST_W-GLITTER_GOLD-RED-NATURAL-WHITE_CHRISTMAS_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23420/11716907/G915240__62571.1769461056.jpg?c=1
68104P_DOG_TOY_CANVAS_AQUATIC_3_ASST_FISH-STARFISH-SEASHELL_IN_PDQ_P32117.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16056/12137676/b62a8ce0-16c7-4f9f-9b9a-f23e39642024_68104P%2520%2520%2520%2520%2520%2520%2520.__51737.1791366254.jpg?c=1
69175P_DOG_TOY_BIRTHDAY_PLUSH_HAT3_ASST_DESIGNS_11_INCH_IN_PDQ_P32897.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16164/12143666/c1729602-4805-4427-8a33-4dc6c15d78bf_69175P%2520%2520%2520%2520%2520%2520%2520.__56798.1791407144.jpg?c=1
69248P_DOG_TOY_PLUSH_SQUEAKER_HAPPY_BIRTHDAY_PINK_4_ASSORTED_IN_PDQ_P34935.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30936/11708606/69248P__47916.1766093879.jpg?c=1
69202P_DOG_TOY_VINYL_BAT_WITH_SQUEAKER_7_INCH_4_ASSORTED_DESIGNS_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27666/12144474/e030e3c7-b6a3-476f-abdb-1cc48d0514e1_69202P%2520%2520%2520%2520%2520%2520%2520.__97373.1791408173.jpg?c=1
66907P_DOG_TOY_VINYL_WITH_SQUEAKER6_ASST_FOOD_DESSERTS_IN_PDQ_HANG_TAG_S20121.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15902/12143638/5d52c6ad-e72a-4475-ac55-3e921a8c2545_66907P%2520%2520%2520%2520%2520%2520%2520.__05545.1791407108.jpg?c=1
G91773_CHRISTMAS_LIGHT_BULB_SOLAR_HANGING_DECOR_PLASTIC_6.5IN_4AST_COLORS-12P.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33743/11718120/G91773__53909.1774989242.jpg?c=1
G91928T_JUTE_TWINE_CHRISTMAS_24PC_150FT_RED-GREEN-NATURAL_SHRINK_LABEL_COUNTER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23591/11718122/G91928T__58220.1774989417.jpg?c=1
G91665_CHRISTMAS_GARLAND_5FT_L_3_ASST_CLRS-_FOAM_STARS_&_BALL-_XMAS_HEADER-_P.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30765/10816631/G91665__48026.1758748022.jpg?c=1
69140P_DOG_TOY_PLUSH_SEA_ANIMALS_4_ASST_HANG_TAG_IN_PDQ_P32584.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16137/12143663/64d78d42-e7bd-4a8a-8427-a48eb802bf37_69140P%2520%2520%2520%2520%2520%2520%2520.__17852.1791407138.jpg?c=1
G91468_ORNAMENT_SHAPED_PUFFY_SANTA_BAG_6AST_3.625_X_1_X_5.5IN_CHRISTMAS_HEADE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23370/9515374/G91468__21540.1750959195.jpg?c=1
G91669_NECKLACE_CHRISTMAS_LIGHT-UP_8_LED_TREE-_SANTA-CANE-STOCKING_XMAS_TCD-_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30790/11719716/G91669__43855.1781726599.jpg?c=1
79233_PEZ_CHRISTMAS_6_ASSORTED_DISPENSERS_AND_3_PEZ_CANDY_REFILLS_BLISTER_PA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/28139/12144488/b5907fc4-bd9c-4f4a-b2e1-6097d6b0b6ce_79233%2520%2520%2520%2520%2520%2520%2520%2520.__17363.1791408190.jpg?c=1
G91831_STOCKING_CHRISTMAS_PLAID_4AST_17IN_W-WHITE_FURRY_CUFF_FELT_BACKED-JHOO.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33832/11718403/G91831__69546.1777582258.jpg?c=1
G91268_CANDY_BUCKET_W-LID_PLASTIC_3AST_CHRISTMAS_PRINTS-COLORS_4.75X4X4.25H_X.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23187/11716969/G91268__35847.1770138212.jpg?c=1
G91771_YARD_STAKE_METAL_CHRISTMAS_GINGERBREAD_3AST_18.2_X_10.5IN_2_PRONG-UPC_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33737/11718119/G91771__20178.1774989159.jpg?c=1
G91929_TREAT_BAG_FELT_3ASST_PENGUIN-GINGERBREAD-DEER_W-FRINGE_TRIM_7.87X10IN_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23593/11718142/G91929__04363.1775164730.jpg?c=1
G91269_COOKIE_CONTAINER_W-SCALLOP_LID_SQUARE_4ASST_CHRISTMAS_PRINTS_7X7X4.7IN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23189/12144130/883b798a-c2a4-49cd-87d4-b719c3e6c540_G91269%2520%2520%2520%2520%2520%2520%2520.__47420.1791407724.jpg?c=1
G91481_WALL_PLAQUE_CHRISTMAS_HORIZONTAL_4AST_MDF_23.6_X_0.5_X_5.2IN_COMPLY-LA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23381/9515369/G91481__76656.1750958883.jpg?c=1
G89140_SKELETON_ANIMAL_DOG_W-BONE_11.5IN_H_X_21IN_L_HLWN-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33588/11718183/G89140__63743.1775747902.jpg?c=1
G91700_SUNCATCHER_PAINT_KIT_CHRISTMAS_W-_BEAD_LEGS_3_ASST_ELF-_DEER-_SNOWMAN_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30880/12134808/c4770d2f-fdcf-4dd0-9939-30dbacd0d398_G91700%2520%2520%2520%2520%2520%2520%2520.__47541.1791342839.jpg?c=1
8232_GIFT_BOX_CHRISTMAS_2PK_SHIRT_KRAFT_14.25_X_9.43_X_1.87_RANDOM_ASSORTED.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30665/11903401/8232__90381.1788900284.jpg?c=1
G91104_ICE_CUBE_TRAY_TPR_CHRISTMAS_3_AST_TREE-FLAKE-GINGERBRD_4.125X7.8IN_XMA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23024/12144110/b4c4e5f4-9a86-459e-9364-7885535bb66b_G91104%2520%2520%2520%2520%2520%2520%2520.__02392.1791407698.jpg?c=1
67014P_DOG_TOY_TPR_BALL_3_INCH_3_ASST_STYLES_2_COLORS_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15944/12143648/dcd863f3-153d-4cbb-96d8-5ded3ee74613_67014P%2520%2520%2520%2520%2520%2520%2520.__89033.1791407120.jpg?c=1
60507_DOG_TREATS_4-5_INCH_KNOTTED_BONE_RAWHIDE_CHEW_BEEF_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15426/12143615/d0e45cbe-67b4-45a6-90ad-2a0f702cfa3f_60507%2520%2520%2520%2520%2520%2520%2520%2520.__76852.1791407081.jpg?c=1
66908PN_DOG_TOY_ROPE_CHEWS_XL_6_ASSORTED_STYLES_HANG_TAG_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15903/12143639/cb7061a2-e8cf-400e-9297-90afd5b15fa3_66908PN%2520%2520%2520%2520%2520%2520.__85695.1791407109.jpg?c=1
G91923M_GIFT_BAG_CHRISTMAS_2PK_MEDIUM_6_X_4_X_8_12_ASST_BARBELL_HDR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30957/11717861/G91923M__07706.1771969128.jpg?c=1
B3116-3114_CHRISTMAS_WORD_FINDS_2_DIGEST_48_AND_2_FULL_SIZE_36_IN_7_POCKET_FLOOR_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33894/11717020/B31163114__13708.1770653837.jpg?c=1
G91569_GIFT_BAG_CHRISTMAS_DRAWSTRING_CANVAS_PRINT_2PK_SMALL-MED_OR_SINGLE_LAR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27314/11718220/G91569__84323.1775762663.jpg?c=1
G91231_COOKIE_CONTAINER_W-SCALLOPED_LID_3AST_CHRISTMAS_PRINTS-7.8DIA_X4.6INH_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23154/11716828/G91231__35092.1768510344.jpg?c=1
G89554_SKELETON_ANIMAL_JUMBO_LIGHT-UP_EYES_13IN_OWL-12.5IN_DOG_HLWN_HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/22413/11719268/G89554__48743.1779221940.jpg?c=1
G91748_WALL_PLAQUE_TRADITIONAL_CHRISTMAS_MDF_6AST_2EA_VERT-HORIZ-SLED-SHAPE_E.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33701/11716926/G91748__04833.1769546369.jpg?c=1
G91766_TAKEOUT-MEAL_PREP_CHRISTMAS_CONTAINERS_42OZ_10PC-5_LIDS-5_TRAYS-SLEEVE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33729/11718469/G91766__29247.1778076070.jpg?c=1
G91752_GIFT_BAG_PAPER_CHRISTMAS_LARGE_10X12X4.7IN_FASHION_BRIGHT_PINK_THEME_8.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33702/12145097/dbbce54e-8021-46ec-873b-24448de36c6b_G91752%2520%2520%2520%2520%2520%2520%2520.__43657.1791408959.jpg?c=1
68037P_DOG_TOY_PLUSH_6IN_EMOTICONS_W-SQUEAKER_6_ASST_FACES_IN_PDQ_P30936.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15999/12137630/4e12a7ef-33d0-4d48-a5e2-2d7def90a389_68037P%2520%2520%2520%2520%2520%2520%2520.__12389.1791366204.jpg?c=1
66919_DOG_TOY_VINYL_W-SQUEAKER_2_ASST_NEWSPAPER_&_DUMBELL_ON_CHAIN_S11100-S1.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15908/12137568/0a640a66-bac7-4b06-95c4-27ffc18f399b_66919%2520%2520%2520%2520%2520%2520%2520%2520.__15667.1791366138.jpg?c=1
69215P_DOG_TOY_SHARK_PLUSH_WITH_SQUEAKER_10_INCH_4_ASSORTED_IN_PDQ_REF_P33838.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27842/12097694/75b7e968-1a2b-47ae-a380-27c860e9ab53_69215P%2520%2520%2520%2520%2520%2520%2520.__42746.1790976088.jpg?c=1
69146P_DOG_TOY_VINYL_ONE-EYED_MONSTER_ASSORTED_COLORS_HANG_TAG_IN_PDQ_S20915.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16143/12137723/127a3995-7ee9-46b7-b210-80713868beb2_69146P%2520%2520%2520%2520%2520%2520%2520.__12710.1791366302.jpg?c=1
60025_DOG_TREATS_8-9_INCH_MUNCHY_JUMBO_BONE_RAWHIDE_CHEW_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15341/12143610/e917d194-4b9e-43e1-a0c8-7331fa36d0a8_60025%2520%2520%2520%2520%2520%2520%2520%2520.__16073.1791407071.jpg?c=1
66935P_DOG_TOY_ROPE-RUBBER_TUG_CHEWS3_STYLES_3_COLORS_IN_PDQ_14072ASST_4.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15915/12143643/588ffc63-0471-4ce0-b295-d32e7b3a0d87_66935P%2520%2520%2520%2520%2520%2520%2520.__19178.1791407114.jpg?c=1
69191P_DOG_TOY_HALLOWEEN_VINYL_W-SQUEAKER_3_ASST_CHARACTERS_IN_PDQ_REF_S21322.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27610/11773795/e3524011-8a34-40aa-9530-960aa4d95b84_69191P%2520%2520%2520%2520%2520%2520%2520.__88037.1787830680.jpg?c=1
68033P_DOG_TOY_PLUSH_BONE_W-ROPE_AND_SQUEAKER_14IN_4_COLORS_IN_PDQ_P30938.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15995/12143651/edf772a1-6cf9-472d-b079-2c06d7c64ebd_68033P%2520%2520%2520%2520%2520%2520%2520.__48310.1791407123.jpg?c=1
69136P_DOG_TOY_PLUSH_W-ROPE_4_ASST_FOODS_HANG_TAG_IN_PDQ_P32587.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16133/5887495/69136P__70017.1729784449.jpg?c=1
G91364_RIBBON_WIRE_CHRISTMAS_2.5X3YDS_12AST_IN_2-24PC_PDQ'S_PER_CASE_6AST_PER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23281/11718480/G91364__19335.1778101636.jpg?c=1
G91396_LOOT_BAG_ZIPPER_10CT_CHRISTMAS_3AST_PRINTS_TO-FROM_XMAS-HDR_6.37_X_9.2.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23313/11718060/G91396__97711.1773865167.jpg?c=1
69149P_DOG_TOY_PLUSH_HALLOWEEN_ASSORTED_4_DESIGNS_HANG_TAG_P32581_COUNTER_DIS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16146/12137726/b0e9be85-eee9-49db-a75b-4afe880960b5_69149P%2520%2520%2520%2520%2520%2520%2520.__94978.1791366306.jpg?c=1
68039P_DOG_TOY_PLUSH_SEA_ANIMAL_ASST_W-SQUEAKER_ASST_COLORS_IN_PDQ_P30952.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16001/12143654/be8e08f2-ef01-4b66-aa39-798532a8bbe5_68039P%2520%2520%2520%2520%2520%2520%2520.__75026.1791407127.jpg?c=1
68105P_DOG_TOY_CANVAS_BONE_9.5_INCH_4_ASST_ANIMAL_PRINTS_IN_PDQ_P32116.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16057/12143661/40a53813-862e-4ba9-b0e5-e018669ac3ce_68105P%2520%2520%2520%2520%2520%2520%2520.__50276.1791407135.jpg?c=1
69104P_DOG_HARNESS_RANDOM_YARN_PRINT_COLORS_3_SIZES_CARDED-PEGGABLESMALL-MEDI.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16103/12137695/350fa31d-1707-4e74-9546-4960f91bd8ec_69104P%2520%2520%2520%2520%2520%2520%2520.__47236.1791366274.jpg?c=1
68107P_DOG_TOY_CANVAS-RUBBER_BONE_9.5_INCH_4_ASST_COLORS_IN_PDQ_P32105.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16059/12137679/c64fa33b-4c65-40f8-b95e-03060671d954_68107P%2520%2520%2520%2520%2520%2520%2520.__96333.1791366257.jpg?c=1
69145P_DOG_TOY_PLUSH_8IN_BONE_ASSORTED_DESIGNS-COLORS_HANG_TAG_IN_PDQP32585.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16142/12137722/41d14a60-1abf-41c9-83dd-a9d4a2ea2330_69145P%2520%2520%2520%2520%2520%2520%2520.__96303.1791366301.jpg?c=1
69246P_DOG_TOY_PLUSH-RUBBER_TURTLE_SPIKE_BALL_3_COLORS_IN_PDQ_REF_407825.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30950/11823566/f5c65c4a-0eb2-4217-a18d-7db6211eea33_69246P%2520%2520%2520%2520%2520%2520%2520.__00608.1788212343.jpg?c=1
G23213_CAMPFIRE_BAMBOO_ROASTING_STICK_8PK_30INL-6MM_FOR_HOT_DOG-MARSHMALLOWS_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/20673/12139639/ff35a9b6-4320-4339-8317-9347f2cd8e01_G23213%2520%2520%2520%2520%2520%2520%2520.__29406.1791368376.jpg?c=1
G91750_GIFT_TAGS_CHRISTMAS_12CT_DIECUT_W-STRING_3AST-4STYLES_PER_PK_HOTSTAMP-.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33699/11717055/G91750__84783.1771018950.jpg?c=1
G91445_CHRISTMAS_MINI_TREE_11_PINE_W-_BURLAP_BASE_&_4_ASST_TRIM_DECOR_XMAS_HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23345/11718114/G91445__93970.1774988821.jpg?c=1
G91084T_BOW_CHRISTMAS_GOLD_OR_RED_JUMBO_11_X_22IN_L_GLITTERED_BURLAP_LOOK_XMAS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33821/11718213/G91084T__72836.1775761957.jpg?c=1
G91284_COOKIE_CUTTER_CHRISTMAS_4PK_PP_PLASTIC_W-MESH_BAG_IN_27PC_PDQ_STYLES_R.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23203/11718058/G91284__89524.1773864979.jpg?c=1
G91833_STOCKING_CHRISTMAS_3AST_EMBROIDERED_18IN_W-CURLY_PLUSH_CUFF_SANTA-REIN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33833/11718139/G91833__48800.1775164549.jpg?c=1
99001_GIFT_BAG_CHRISTMAS_BE_GOOD_I_WILL_TEXT_SANTA_RED-BLACK_7.5_X_10_X_4.5.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17949/12138396/9ffe6222-2434-4962-a271-b5659e2d0e11_99001%2520%2520%2520%2520%2520%2520%2520%2520.__93061.1791367027.jpg?c=1
G89045_PET_COSTUME_PLUSH_HEAD_HAT_6_ASST_SMALL_DOG-_CAT_POLYESTER_EA-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30656/12068372/e2c4024b-bc39-41a2-b435-9ecf3e1264f5_G89045%2520%2520%2520%2520%2520%2520%2520.__33692.1790681580.jpg?c=1
30100N_GIFT_WRAP_CHRISTMAS_100_SQ_FT1.5IN_CORE_ASST_DESIGNS_PP_6.99_30_INCH_W.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/12191/12143515/4c787e86-1865-4eba-8e82-2f947f4bd955_30100N%2520%2520%2520%2520%2520%2520%2520.__23125.1791406964.jpg?c=1
G91795_CHRISTMAS_BELL_ORNAMENT_4TIER-_7.48IN_RED-SILVER-GOLD_W-GREENERY_XMAS_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33782/11717031/G91795__26856.1770667413.jpg?c=1
G91358_DINNERWARE_KIDS_CHRISTMAS_2ASST_SPACE_AGE_SANTA-ELF_3-SECTION_PLATE-_B.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23276/11717041/G91358__70732.1770759357.jpg?c=1
G91082N_GLASSES_CHRISTMAS_NOVELTY_6AST_REINDEER-_TREE-_SANTA-_ELF-_SNOWFLAKE_X.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30882/11700416/4027dc9f-b47b-4691-98b5-713b2937553b_G91082N__56950.1763655417.jpg?c=1
G91251_HEADBAND_CHRISTMAS_NOVELTY_LIGHT-UP_LED_5AST_DELUXE_STYLES_JHOOK-HT_&_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23170/11708288/1f1d18df-5994-4adc-8d25-62d5581da730_G91251%2520%2520%2520%2520%2520%2520%2520.__83218.1765793097.jpg?c=1
G91934CS_GIFT_TAGS_60CT_LASER_CHRISTMAS_6AST_24PC_MDSG_STRIP_XMAS_PB-INSERT_HDR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25518/11718168/G91934CS__39889.1775593145.jpg?c=1
G91614T_TRAY_SERVING_CHRISTMAS_TREE_SHAPED_SANTA-DEER-TREE_PRINT_12IN_PP_PLAST.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23444/12144159/8ea75309-7731-4f7a-a850-361eb120010f_G91614T%2520%2520%2520%2520%2520%2520.__85993.1791407760.jpg?c=1
G91759_CHRISTMAS_WINE_BOTTLE_COVER-GIFT_BAG_3AST_W-SEQUIN_HAT_SANTA-SNOWMAN-R.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33716/11718117/G91759__53282.1774989038.jpg?c=1
66745PN_DOG_TOY_AQUA_FLOATABLE_W-SQKR_BLUE-YELLOW_4_STYLES_IN_PDQ_HANG_TAG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15859/12137538/c60fb6de-fd02-4ae7-bb12-4c9c55b430d7_66745PN%2520%2520%2520%2520%2520%2520.__58522.1791366107.jpg?c=1
8231_GIFT_BOX_CHRISTMAS_JUMBO_PRINTED_TOP_WHITE_BOTTOM_14_X_20_X_4_RANDOM_A.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30664/12144710/98790c51-20cc-4695-9f86-fe85550c3608_8231%2520%2520%2520%2520%2520%2520%2520%2520%2520.__44817.1791408471.jpg?c=1
G91772_SHELF_SITTER_CHRISTMAS_FIGURES_W-DANGLE_LEGS_6AST_GINGER-DEER-ELVES_13.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33755/11716702/G91772__86294.1768327159.jpg?c=1
40040T_GIFT_WRAP_CHRISTMAS_40_SQ_FT6_ASSTD_40IN_WIDE_PP_3.991.5_INCH_CORE_MAD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/12962/12143540/7905dad6-9c9b-475e-8caa-b0b50f81e56d_40040T%2520%2520%2520%2520%2520%2520%2520.__70605.1791406992.jpg?c=1
G91769_TREAT_BOX_CHRISTMAS_4PK-4_DESIGNS_PER_SET-2AST_COMBOS_6.3_X_9.84IN_XM-.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33754/11716928/G91769__91829.1769546546.jpg?c=1
G91636_FOOD_STORAGE_CONTAINER_CHRISTMAS_ROUND-OCTAGON_4_DESIGNS_-_7IN_DIA_XMA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30742/12144726/ffe51526-4c57-4156-8809-20c3296f8b13_G91636%2520%2520%2520%2520%2520%2520%2520.__01250.1791408490.jpg?c=1
66883PN_DOG_TOY_VINYL_HIGH-TOP_SNEAKERWITH_SQUEAKER_4_COLORS_IN_PDQ_HANG_TAG_S.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15897/12137561/34d4fbcb-35ea-4b29-b080-fa20c87074d0_66883PN%2520%2520%2520%2520%2520%2520.__75929.1791366130.jpg?c=1
66981P_DOG_TOY_ROPE_CHEWS_6_ASSORTED_STYLES-MULTI-COLOR_IN_PDQ_HANG_TAG_C1506.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15930/12137584/be659c89-a529-4857-bd27-e9eacecd546b_66981P%2520%2520%2520%2520%2520%2520%2520.__66713.1791366156.jpg?c=1
G91763CS_GIFT_BAG_2PK_7.8X5IN_CHRISTMAS_FAUX_BURLAP_PRINTS_W-DRAWSTRING-6AST_ON.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33719/11717366/G91763CS__89262.1771440262.jpg?c=1
G23211_BBQ_CAMP_FORK_42IN_LONG_2-PRONG_FOR_HOT_DOGS_OR_MARSHMALLOWS_BBQ_PRINT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/20672/12139638/6748b403-949f-4231-b60d-484556d72117_G23211%2520%2520%2520%2520%2520%2520%2520.__98476.1791368374.jpg?c=1
69190P_DOG_TOY_PUMPKIN_HALLOWEEN_SQUEAKER_4_ASSORTED_FACE_DESIGNS_REF_P33800_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27609/12010922/eb430332-f4ab-4a0d-96b9-87e78ee3df5a_69190P%2520%2520%2520%2520%2520%2520%2520.__38798.1790026125.jpg?c=1
69173P_DOG_TOY_PLUSH_HALLOWEEN_SPOOKY_DRINK_4_ASSORTED_HANG_TAG_P32933_COUNTE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16162/12137735/1753fd76-dc94-48c7-9ab5-7fc61abe7222_69173P%2520%2520%2520%2520%2520%2520%2520.__58400.1791366316.jpg?c=1
G91479_WALL_PLAQUE_CHRISTMAS_MDF_4AST_4-SECTION_7.9_X_0.7_X_8.9IN_COMPLY_LABE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23379/11716986/G91479__70819.1770321065.jpg?c=1
276842_DOG_TREATS_AMERICAN_BEEFHIDE_4PK_5_INCH_TWISTEDZ_STICKS_REAL_BEEF_WRAP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/11961/12136196/e24a4141-bdb2-4e5b-b170-45a4acc63d15_276842%2520%2520%2520%2520%2520%2520%2520.__86685.1791364645.jpg?c=1
5066_DOG_TREATS_YUMMY_BONES_GRAIN-FREE_2.8_OZ_BACON_COUNTER_DISPLAY_MADE_IN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14400/12143580/96b33744-d6ec-4a22-ad84-9d80f8bccb2b_5066%2520%2520%2520%2520%2520%2520%2520%2520%2520.__93266.1791407037.jpg?c=1
69174P_DOG_TOY_PLUSH_HALLOWEEN_3_ASSORTED_POISON_BOTTLE_HANG_TAG_P32931_COUNT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16163/12137736/5a5944bf-2751-4afd-8304-f83bba479c04_69174P%2520%2520%2520%2520%2520%2520%2520.__51107.1791366317.jpg?c=1
60505_DOG_TREATS_4-5_INCH_KNOTTED_BONE_RAWHIDE_CHEW_PEANUT_BUTTER_COUNTER_DI.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15425/12137384/2f270055-6a7c-4a15-89b7-5f072af26a04_60505%2520%2520%2520%2520%2520%2520%2520%2520.__31482.1791365950.jpg?c=1
HA223_GIFT_BAG_CHRISTMAS_3_SIZES_W-SPINNER_RACK_96_LG_72_MED_48_XL_-_216_PC.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25089/12144249/644e7040-e080-4a97-9663-11071e924261_HA223%2520%2520%2520%2520%2520%2520%2520%2520.__96772.1791407886.jpg?c=1
G91922M_GIFT_BAG_SMALL_3PK_CHRISTMAS_4_ASST_COMBOS_4.25_X_5.25_X_2.25IN_BARBEL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30956/11717860/G91922M__45357.1771969059.jpg?c=1
66938P_DOG_TOY_DOUBLE_KNOTTED_ROPE-RUBBER_CHEWS_3_STYLES_3_COLORS_IN_PDQ_1407.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15916/12137576/b3d64c1e-0b98-496e-b05d-994c3792ff38_66938P%2520%2520%2520%2520%2520%2520%2520.__65218.1791366147.jpg?c=1
5065_DOG_TREATS_YUMMY_BONES_GRAIN-FREE_2.8_OZ_CHICKEN_COUNTER_DISPLAY_MADE_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14399/12143579/d4121639-e0a3-4ccb-8ed4-d1738bfb0c32_5065%2520%2520%2520%2520%2520%2520%2520%2520%2520.__20791.1791407036.jpg?c=1
G91726_HAT_CHRISTMAS_PLUSH_W-PUMP_UP_EAR_MOTION_3AST_SANTA-ELF-DEER_10X20IN_H.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33194/11694638/41b6ef36-15f3-413d-8512-e3c0889b0f9f_G91726__91977.1763644547.jpg?c=1
G91799_BELL_CHRISTMAS_HANGING_DECOR_6..5X6IN_PLASTIC_W-TINSEL_HANGER_AND_BOW_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33787/11718307/G91799__17958.1776285524.jpg?c=1
69172P_DOG_TOY_PLUSH_HALLOWEEN_3_ASSORTED_FACE_STYLES_HANG_TAG_P32920_COUNTER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16161/12137734/bdc02c08-6749-4517-a7cd-fc0a59c8e541_69172P%2520%2520%2520%2520%2520%2520%2520.__96193.1791366315.jpg?c=1
G91856_WREATH_CHRISTMAS_12IN_W-PINE_&_BERRIES_4AST_RED-SILVER-GOLD_BERRY_&_FR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33850/11717851/G91856__42489.1771881652.jpg?c=1
G91842_NOTEBOOK_CHRISTMAS_PETS_IN_SANTA_HATS_W-PEN_4AST_IN_24PC_PDQ_3.75INX5..jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33840/11718167/G91842__78057.1775592985.jpg?c=1
G91707_PET_STOCKING_2_ASST_16_X_8.5IN_16_DOG-_8_CAT_-_XMAS_HT-_JHOOK.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30938/12126160/41063c0f-0b19-4461-bf0a-1cfc65adb38b_G91707%2520%2520%2520%2520%2520%2520%2520.__05299.1791236072.jpg?c=1
G91632CS_CAN-BOTTLE_SLEEVE_CHRISTMAS_PRINTS_4_ASST_NEOPRENE_-_24PC_PRELOADED_MD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30727/11718116/G91632CS__72272.1774988957.jpg?c=1
G91760_GIFT_BAG_CHRISTMAS_NON-WOVEN_REUSABLE_JUMBO_18.5_W_X_19.875_H_X_5IN_G-.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33718/11718379/G91760__17396.1777062623.jpg?c=1
G91828S_HAT_CHRISTMAS_LONG_4AST_NOVELTY_SHAPEABLE_ADULT_SIZE_25-33INL_W-12IN_P.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27590/11718228/G91828S__50340.1775853682.jpg?c=1
69243P_DOG_TOY_15_INCH_PLUSH_WITH_TREAT_DISPENSER_2_ASSORTED_MONKEY_FLAMINGO_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30932/12144774/0acea016-5f6e-4ac3-bd07-797b076e2697_69243P%2520%2520%2520%2520%2520%2520%2520.__77333.1791408548.jpg?c=1
56477N_CHRISTMAS_PEEPS_VANILLA_FLAVOR_CHICK_DISPLAY_CHICK_POPS_4CT_ASST_COLOR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25386/12125572/76d368d1-9584-4d95-a8df-5a58db009fa7_56477N%2520%2520%2520%2520%2520%2520%2520.__80101.1791235300.jpg?c=1
G91039_PUFF_CHRISTMAS_CHARACTER_LITE-UP_SQUEEZE_STOCKING_STUFFER_2X12PC_PDQ_T.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/22948/11719634/G91039__56611.1781124344.jpg?c=1
890103_DOG_TOY_TENNIS_BALLS_ASSORTED_3PK_2.5_INCH_2_SOLID-1_PRINT_IN_MESH_BAG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26175/12144348/56383a90-40f4-4867-bbaa-ca0df73040bf_890103%2520%2520%2520%2520%2520%2520%2520.__87981.1791408012.jpg?c=1
G911760N_CHRISTMAS_10_LED_10_ICON_STRING_LIGHTS_FLAKE-_BALL-_BULB_6FT-_BATT_NOT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30892/11717870/G911760N__94950.1772051652.jpg?c=1
5067_DOG_TREATS_YUMMY_BONES_GRAIN-FREE_2.8_OZ_PEANUT_BUTTER_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/14401/12143581/27841585-85ae-4d74-b80f-a97467bae2e5_5067%2520%2520%2520%2520%2520%2520%2520%2520%2520.__10574.1791407038.jpg?c=1
G91654_BOW_CHRISTMAS_PLAIDS_1-_6_X_10IN_OR_2PK_5.5_X_8IN_4_ASST_PRINTS_XMAS_T.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30746/12119729/ec776ee8-f94d-4f72-84a1-be058c745050_G91654%2520%2520%2520%2520%2520%2520%2520.__24139.1791197346.jpg?c=1
G91729_COOKIE_CONTAINER_ROUND_W-LID_&_HANDLE_3AST_CHRISTMAS_PRINTS_12.91_X_12.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33199/11387548/f405d7e7-baba-4ea9-8c85-8ae5ee9115bb_G91729__71475.1761927327.jpg?c=1
69139P_DOG_TOY_SPIKE_BALL_TPR_3_ASST_COLORS_MESH_BAG-HANG_TAG_IN_PDQ_GT12123.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16136/12137716/90d9f40c-4b55-4ea8-8880-18137900821d_69139P%2520%2520%2520%2520%2520%2520%2520.__41141.1791366295.jpg?c=1
69141P_DOG_TOY_PLUSH_8_INCH_BONE_POLK_A_DOT_DESIGN_ASST_HANG_TAG_IN_PDQ_P3258.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16138/12137718/1a2ee24c-fe2f-4182-8642-ff44cfc40b74_69141P%2520%2520%2520%2520%2520%2520%2520.__61409.1791366297.jpg?c=1
G91660_MUSIC_BOX_MINI_WOODEN_2.5_X_2.125_3_ASST_CHRISTMAS_SONGS_IN_PEGGABLE_P.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30754/12144729/982219de-564b-4739-9431-c5c1bef11b1a_G91660%2520%2520%2520%2520%2520%2520%2520.__40810.1791408494.jpg?c=1
G91809_CHRISTMAS_TREE_GREEN_FROSTED_BOTTLE_BRUSH_LIGHT-UP_3ASST_SIZES_6.3-6.7.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33808/11717849/G91809__31895.1771881508.jpg?c=1
G91629_COASTER_CORK_4PK_3.5IN_DIA_4ASST_CHRISTMAS_PRINTS_IN_24PC_PDQ-EA_SET_S.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30737/12144724/f7a49e48-5a97-4750-8860-28b311c1a9d3_G91629%2520%2520%2520%2520%2520%2520%2520.__14660.1791408488.jpg?c=1
G91596_2-TIER_TRAY_CHRISTMAS_MDF-_BOTTOM_11.7DIA_-TOP_8.6IN_DIA_13.87IN_H-GRE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27476/11716987/G91596__92983.1770321178.jpg?c=1
300309N_GIFT_WRAP_CHRISTMAS_30_SQ_FT30_INCH_X_12_FOOT_PPD_3.99_RANDOM_PRINTS_O.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/12180/12143514/4fa1cd44-19e4-43fb-836e-25fb3a6b0849_300309N%2520%2520%2520%2520%2520%2520.__39139.1791406962.jpg?c=1
G91638_WINDOW_LIGHTUP_DECOR_CHRISTMAS_4_ASST_LR44_BATT-_INC_W-_SUCTION_CUP_IN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30682/12144711/ae5d5497-e316-489b-a363-e2298912cf69_G91638%2520%2520%2520%2520%2520%2520%2520.__50860.1791408472.jpg?c=1
G91755_GIFT_BAG_CHRISTMAS_LARGE_CUTE_PETS_W-FURRY_HANDLE_6AST_10.2_X_5_X_12.7.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33704/11719546/G91755__93715.1780412375.jpg?c=1
G91970T_COOKIE_BOX_2PK_CHRISTMAS_4_AST_DESIGNS_W-_BUILT_IN_BOW_XMAS_PBH_4.25W_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30722/12144186/4f3f17e6-3f73-42f1-ac99-98e7642d8f9a_G91970T%2520%2520%2520%2520%2520%2520.__67859.1791407793.jpg?c=1
G91113_COOKIE_TRAY_KIT_CHRISTMAS_2_PRNTD_PAPER_TRAYS-_2_CELLO_BAGS-RIBBONS-TA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23035/11716985/G91113__24238.1770320987.jpg?c=1
G87328_CUTOUT_FELT_JOINTED_VALENTINE_FIGURES_HANGING_DECOR_4_ASST_BEAR-DINO-D.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/28872/12144543/342afa8c-9f38-45c8-865c-761c5a993dce_G87328%2520%2520%2520%2520%2520%2520%2520.__74976.1791408254.jpg?c=1
G91811_CHRISTMAS_TREE_BOTTLE_BRUSH_SNOW_TIPPED_W-5_B-O_LIGHTS_5.9_X_2.4IN_4AS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33812/11719284/G91811__06060.1779223535.jpg?c=1
G91505_GEL_CLING_STICKERS_LITEUP_CHRISTMAS_3AST_IN_TRY-ME_PKG_24IN_L_2-CR-203.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23403/11717844/G91505__34906.1771881150.jpg?c=1
69198P_DOG_TOY_HALLOWEEN_PLUSH_W-ROPE_&_SQUEAKER_4_ASSORTED_DESIGNS_HANG_TAG_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27608/11926518/5f6eff4a-f9d1-44f3-809c-1765a31b30de_69198P%2520%2520%2520%2520%2520%2520%2520.__80094.1789075429.jpg?c=1
G91508_CHRISTMAS_TREE_TABLE_DECOR_COLOR_CHANGE_LIGHT-UP_PLASTIC_3AST_COLORS_2.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/24871/11717978/G91508__62484.1772825105.jpg?c=1
8007_COLORING_ACTIVITY_BOOK_CHRISTMAS320PG_4_ASSORTED.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/17068/12143708/3dd4df0b-d830-441c-9a6d-3e0e6ea0dac4_8007%2520%2520%2520%2520%2520%2520%2520%2520%2520.__43001.1791407194.jpg?c=1
G91635CS_BAKING_CUPS_MINI_FOIL_48CT_1.25IN_4_ASST_COLORS_GOLD-_SILV-_RED-_GREEN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30732/11702587/4ffe19e9-1287-4505-becf-e9708decc423_G91635CS%2520%2520%2520%2520%2520.__97175.1763691079.jpg?c=1
G91969-24_STOCKING_PET_6AST_FELT_18IN_16DOG-8CAT_W-FUN_SAYINGS_RED-GREEN_JHOOK-H.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33752/11718309/G91969-24__91391.1776285648.jpg?c=1
G87361_PARTY_FAVOR_VALENTINE_EXCHANGE_MULTI-PACKS_6AST-PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/34410/12145345/8052857f-13e9-4dbf-a11f-7d36c329da2b_G87361%2520%2520%2520%2520%2520%2520%2520.__47155.1791409274.jpg?c=1
1601_PET_SHAMPOO_14OZ_CALMING_LAVENDER&LEMON_GRASS_PET_CARE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25769/11716910/1601__49848.1769536521.jpg?c=1
1602_PET_SHAMPOO_14OZ_SKIN_SOOTHING_ALOE_&_STRAWBERRY_PET_CARE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25771/11716911/1602__09160.1769540827.jpg?c=1
8033_PET_SHAMPOO_14OZ_FLEA&TICK_W-PEPPERMINT_OIL_&_GURENID_PETCARE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30997/11716939/8033__51523.1769547357.jpg?c=1
8034_PET_SHAMPOO_14OZ_OATMEAL_HYPO-ALLERGENIC_PETCARE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30998/11716940/8034__84992.1769547420.jpg?c=1
1600_PET_SHAMPOO_PETCARE_ADVANCED_CARE_14_OZ_CITRONELLA_&_TEA_TREE_OIL.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25770/11716915/1600__20986.1769541591.jpg?c=1
IMAGE_LIST_EOF
}
# ----------------------------------------------------------------

TOTAL=$(image_list | grep -c . )
mkdir -p "$OUT" || exit 1
LOG="$OUT/_failed.txt"
: > "$LOG"

echo "Regent Products - dog christmas"
echo "Destination : $(pwd)/$OUT"
echo "Images      : $TOTAL"
echo "Parallel    : $JOBS at a time"
echo
echo "Progress ( . downloaded   s already had it   x failed ):"

fetch_one() {
  local name="$1" url="$2" target="$OUT/$1"
  if [ -s "$target" ]; then printf 's'; return; fi
  if curl -fsL --retry 3 --retry-delay 2 --max-time 180 \
       -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36' \
       -e 'https://regentproducts.com/' \
       -o "$target.part" "$url" 2>/dev/null && [ -s "$target.part" ]; then
    mv -f "$target.part" "$target"
    printf '.'
  else
    rm -f "$target.part"
    printf 'x'
    printf '%s\t%s\n' "$name" "$url" >> "$LOG"
  fi
}

running=0
while IFS=$'\t' read -r name url; do
  [ -n "${name:-}" ] && [ -n "${url:-}" ] || continue
  fetch_one "$name" "$url" &
  running=$((running+1))
  if [ "$running" -ge "$JOBS" ]; then wait -n 2>/dev/null || wait; running=$((running-1)); fi
done < <(image_list | grep .)
wait

echo
echo

GOT=$(find "$OUT" -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.webp' \) 2>/dev/null | wc -l | tr -d ' ')
FAILED=$(grep -c . "$LOG" 2>/dev/null | tr -d ' ')
[ -z "$FAILED" ] && FAILED=0

echo "Downloaded : $GOT of $TOTAL"
if [ "$FAILED" -gt 0 ]; then
  echo "Failed     : $FAILED  - listed in $OUT/_failed.txt"
  echo "             Re-run this script to retry just those."
else
  echo "Failed     : none"
  rm -f "$LOG"
fi

echo
echo "Folder: $(pwd)/$OUT"
echo "Done."
