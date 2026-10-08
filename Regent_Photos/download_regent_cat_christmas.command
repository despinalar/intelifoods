#!/bin/bash
#
#  Regent Products - "cat christmas" search images downloader
#  ---------------------------------------------------------------
#  Downloads the main product image for every product returned by
#  this search on regentproducts.com, EXCLUDING any product that
#  also appeared in the "dog christmas" search:
#
#    https://regentproducts.com/search.php?search_query=cat+christmas&section=product
#
#  HOW TO RUN (macOS)
#    Option A - double-click this file in Finder.
#               (If macOS refuses: right-click it, choose Open,
#                then click Open in the warning dialog.)
#    Option B - open Terminal and run:
#                 bash ~/Downloads/download_regent_cat_christmas.command
#
#  Images are saved into a folder named "Regent_Cat_Christmas",
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

OUT="Regent_Cat_Christmas"
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
G89768N_DRIVEWAY_MARKER_HALLOWEEN_33.5IN_W-PUMP-GHOST-CAT_FACE_REFLECTOR_HALL_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/22619/12152050/ee08643d-9c07-48eb-8fea-70e83f899fe1_G89768N%2520%2520%2520%2520%2520%2520.__17632.1791455977.jpg?c=1
G89694_TRUNK_OR_TREAT_PAPER_CAR_DECOR_KIT_3ASST_CLOWN-SKULL-CAT_HLWN_PB-INSER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/22544/12151996/331e34f2-e001-4ee1-883d-fabd5dc7d032_G89694%2520%2520%2520%2520%2520%2520%2520.__94073.1791455917.jpg?c=1
G91595_STANDING_DECOR_CHRISTMAS_MDF_EASEL_BACK_4AST_APPROX_24X9.5.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27475/12144437/b3bbc1b0-c79d-49c8-8fa1-2a0081d1dd08_G91595%2520%2520%2520%2520%2520%2520%2520.__09438.1791408125.jpg?c=1
G91757_WINE_BOTTLE_CHRISTMAS_COVER_3AST_SANTA-SNOWMAN-REINDEER_KNIT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33714/11718397/G91757__60287.1777581784.jpg?c=1
G91734P_GIFT_BAG_PAPER_MED_CHRISTMAS_6AST_IN_36PC_PDQ_8X4X10IN.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33217/11719582/G91734P__43839.1780604611.jpg?c=1
G91207N_HEADBAND_CHRISTMAS_4AST_TREE-HAT-ANTLERS-SNOWFLAKE_XMAS_TCD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33823/11717039/G91207N__74796.1770759215.jpg?c=1
890073_CAT_TOY_6PK_SPRING_ASSORTED_COLORS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26176/5060117/890073__99320.1724422349.jpg?c=1
G91324_NECKLACE_CHRISTMAS_LIGHT-UP_TPR_4AST_SNOWMAN-SANTA-TREE-FLAKE_PB-INSER.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23242/10816471/G91324__20033.1758747702.jpg?c=1
G91498_BASKET_W-HANDLE_CANVAS_W-LINING_3ASST_CHRISTMAS_PRINTS_6X8IN_XMAS_HANG.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23396/11718227/G91498__71851.1775853619.jpg?c=1
4233_PEZ_CHRISTMAS_DISPENSER-CANDY_INCLUDES_2_ROLLS_CANDY_6_ASSORTED_COUNTE.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/25444/12125580/2e4d285c-1fb6-4852-adc1-d912d7c415c9_4233%2520%2520%2520%2520%2520%2520%2520%2520%2520.__94341.1791235313.jpg?c=1
G91150_ORNAMENT_WOOD_6AST_CHRISTMAS_CHARACTERS_W-LITEUP_NOSES_BATT_INCLUDED_X.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33783/11718159/G91150__40116.1775592300.jpg?c=1
G91676_WALL_PLAQUE_CHRISTMAS_SILV-_GOLD_THEME_6_ASST_GLITTERED_MDF_COMPLY_HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30864/12146273/c34c97af-049b-4f27-9c6d-3aa39b7ec549_G91676%2520%2520%2520%2520%2520%2520%2520.__28057.1791429044.jpg?c=1
890233_CAT_TOY_DANGLER_WAND_6_ASSORTED_IN_PDQ.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27649/12132931/84ed758f-3942-4674-84c2-2bc43f5e51db_890233%2520%2520%2520%2520%2520%2520%2520.__12068.1791321596.jpg?c=1
890042_CAT_TOY_PLUSH_ANIMAL_ASSORTMENT_IN_MESH_MDSE_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26181/12144350/a59effb1-dbc8-4c22-9a4d-da59d4dab3d7_890042%2520%2520%2520%2520%2520%2520%2520.__27813.1791408015.jpg?c=1
890004_CAT_TOY_10PK_ASSORTED_COLORS_IN_24PC_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26171/12097563/619d985d-a379-4f72-940f-25f9941e788a_890004%2520%2520%2520%2520%2520%2520%2520.__95727.1790975923.jpg?c=1
890592_CAT_TOY_CATNIP_FILLED_HALLOWEEN_8_ASSORTED_DESIGNS_ON_CHAIN_MERCH_STRI.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27625/12069232/efb63599-17af-49b1-ae72-cadc52a46a67_890592%2520%2520%2520%2520%2520%2520%2520.__58413.1790694045.jpg?c=1
69254_CAT_MAT_13_X_19_NON-SLIP_RANDOM_DESIGNS.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/31607/12144827/2624dfe4-cd63-48c1-870c-14f554b6cff1_69254%2520%2520%2520%2520%2520%2520%2520%2520.__32220.1791408614.jpg?c=1
890028_CAT_TOY_WITH_.5_OZ_CATNIP_PUFF_BALLS_7PK_ASSORTED_COLORS_IN_COUNTER_DI.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26174/12144347/8e34baee-08da-46bb-94ca-8785f4dc806d_890028%2520%2520%2520%2520%2520%2520%2520.__15325.1791408011.jpg?c=1
890035_CAT_TOY_4PK_MICE_ASSORTED_COLORS_IN_MESH_MDSE_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26183/12144352/a2aa0464-ad88-4316-8b2c-fcb9539b5a86_890035%2520%2520%2520%2520%2520%2520%2520.__06709.1791408017.jpg?c=1
890608_CAT_TOY_HALLOWEEN_DANGLER_WAND_WITH_BELL_ASSORTED_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27626/12084373/4b59546f-8fb1-4556-a377-158e7c39528e_890608%2520%2520%2520%2520%2520%2520%2520.__97843.1790885501.jpg?c=1
890066_CAT_TOY_PLUSH_WITH_CATNIP-CRINKLE_RAINBOW_STRIPE_POLKA_DOT_MESH_MDSE_S.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26177/11936697/6dd81506-ca8d-4b79-adb1-bbf11dda411a_890066%2520%2520%2520%2520%2520%2520%2520.__55746.1789139269.jpg?c=1
69100_CAT_MAT_NON-SLIP_4_ASSORTED_STYLES_13_X_19.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16100/11903364/69100__68648.1788898584.jpg?c=1
69153_CAT_TOY_HALLOWEEN_6_STYLES_ON_12_PC_MERCH_STRIP_CT202112.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16151/12149104/18b76304-edda-4a1b-9845-27d2fdd899e8_69153%2520%2520%2520%2520%2520%2520%2520%2520.__81968.1791452745.jpg?c=1
890097_CAT_TOY_CARDBOARD_ROLLER_9_INCH_WITH_CATNIP_ASSORTED_COLORS_TAIL_AND_R.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26184/12144353/b960b659-e85f-4c21-ac3a-180fe60d79d8_890097%2520%2520%2520%2520%2520%2520%2520.__09962.1791408018.jpg?c=1
890745_CAT_TOY_HALLOWEEN_WAND_18_INCH_6_ASSORTED_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27627/12097679/c207b00a-3099-4b88-b241-c1106b12177f_890745%2520%2520%2520%2520%2520%2520%2520.__46760.1790976069.jpg?c=1
890059_CAT_TOY_BALLS_WITH_TAILS_2PK_ASSORTED_COLORS_IN_CHAIN_STRIP_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26179/12144349/d1696756-25f0-4130-8947-594e0f8e0bb3_890059%2520%2520%2520%2520%2520%2520%2520.__42446.1791408014.jpg?c=1
890196_CAT_TOY_CANDY_CRINKLER_2PK_ASSORTED_COLORS_ON_CHAIN_MERCH_STRIP.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27644/12070381/8df2b538-28f5-4cfb-9e59-063b4ff9984c_890196%2520%2520%2520%2520%2520%2520%2520.__37148.1790717100.jpg?c=1
66976TT_CAT_TOY_PLASTIC_WAND_WITH_BELL_5_STYLES_REF15073_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/15926/11903363/66976TT__18724.1788898540.jpg?c=1
890370_CAT_TOY_HALLOWEEN_CANDY_CRINKLER_2PK_ASSORTED_COLORS_ON_CHAIN_MERCH_ST.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27628/12132926/fbd8f72b-bc72-4e1f-b86f-1142aa7ecf6d_890370%2520%2520%2520%2520%2520%2520%2520.__79854.1791321590.jpg?c=1
69170_CAT_TOY_2PK_HALLOWEEN_TOY_&_BELL_MERCH_STRIP_4_STYLES_P33444.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16159/12149108/82af58cb-ad56-42c4-93c5-72a62935cccb_69170%2520%2520%2520%2520%2520%2520%2520%2520.__84750.1791452749.jpg?c=1
890219_CAT_TOY_LATICE_BALLS_PLASTIC_WITH_BELL_4PK_ASSORTED_ON_CHAIN_MERCH_STR.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27645/12144470/9093806e-6b6d-435a-ac36-c6d23590bfda_890219%2520%2520%2520%2520%2520%2520%2520.__79461.1791408169.jpg?c=1
69177_CAT_TOY_COLORFUL_BIRTHDAY_PLAY_W-FEATHER_4_STYLE_ASSORTMENT_IN_MERCH_S.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/16166/12149114/12d94392-89ed-4c42-a590-ee4927f74e98_69177%2520%2520%2520%2520%2520%2520%2520%2520.__19372.1791452755.jpg?c=1
890752_CAT_TOY_MOUSE_BALL_WITH_BELL_TAIL_2PK_ASSORTED_COLORS_ON_CHAIN_MERCH_S.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27642/12144469/40aa9141-9895-4140-b0e2-6ad4a292aded_890752%2520%2520%2520%2520%2520%2520%2520.__33759.1791408167.jpg?c=1
G89089_COSTUME_KIT_ADULT_DEVIL-BLACK_CAT_3PC_HEADBAND-TAIL-BOW_TIE-FACE_W-TCD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/33461/11713273/5c5dbb62-9030-4c84-8c8f-278894be78ad_G89089%2520%2520%2520%2520%2520%2520%2520.__36346.1767694009.jpg?c=1
890158_CAT_TOY_2_ASSORTED_STYLES_4_INCH_PLASTIC_BALL_WITH_BELL_CYLINDER_WITH_.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27647/12144471/cfd5fb2f-321b-43e0-a5fe-65372439d1ea_890158%2520%2520%2520%2520%2520%2520%2520.__68714.1791408170.jpg?c=1
G89933_STANDING_DECOR_HALLOWEEN_MDF_EASEL_BACK_3AST_CAT-PUMPKIN-GHOST_APROX_2.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/27436/11701556/ffd40cdb-1bd6-4516-bcdf-01c7b7b757fb_G89933__01269.1763657683.jpg?c=1
G41385_ON_THE_GO_SNACK_CATCHER_10_OZ_PLASTIC_HANDLED_BARBELL_CARD.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/29615/9512997/G41385__48827.1750949277.jpg?c=1
890011_CATNIP_.5_OZ_RESEALABLE_PEG_BAG_IN_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26182/12144351/4350d02f-07c7-4240-a248-d26f14acd93f_890011%2520%2520%2520%2520%2520%2520%2520.__81351.1791408016.jpg?c=1
C609_CANDY_POP_&_CATCH_WITH_LOLLIPOP_.39OZ_COUNTER_DISPLAY.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/18259/12149890/c6591300-0032-42e6-8978-f88119de73e2_C609%2520%2520%2520%2520%2520%2520%2520%2520%2520.__92453.1791453590.jpg?c=1
G94025_SUNCATCHER_2PK_DIY_HARVEST_KIT_W-PAINT_3AST_COMBOS-HARV_PBH.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/23690/11903382/G94025__84954.1788899401.jpg?c=1
G94084_HARVEST_DECOR_4_ASST_VASE_FILLER-_SCATTER_PINECONE-_MUSHROOM-_PUMPKIN-.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/30550/11591478/G94084__51090.1763047580.jpg?c=1
G11426CS_DRAIN_HAIR_CATCHER_6_SQ_W-4_SUCTION_CUPS_TPR_WHITE_TCD-_12PC_DISP_STRI.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/29783/12144629/83cb9c8b-fc1b-4dfd-8383-65c9dcda88be_G11426CS%2520%2520%2520%2520%2520.__33217.1791408367.jpg?c=1
G16319_FLASH_PUFFER_CATERPILLAR_LIGHT_UP_10IN_3AST_COLORS_IN_12PC_PDQ_EA_W-HT.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26190/12146099/10a119b2-89a3-40bd-8aca-afaa85ca4d7d_G16319%2520%2520%2520%2520%2520%2520%2520.__73110.1791428821.jpg?c=1
G18322_BUG_CATCH-N-VIEW_KIT_4PC_W-15.75INL_NET_TWEEZER_CLIP_ON_VIEW_JAR_&_TRA.jpg	https://cdn11.bigcommerce.com/s-hjgn9gnt3i/images/stencil/original/products/26075/12144338/6c83d3de-f335-4c43-9d11-c10dcd544a60_G18322%2520%2520%2520%2520%2520%2520%2520.__66860.1791408000.jpg?c=1
IMAGE_LIST_EOF
}
# ----------------------------------------------------------------

TOTAL=$(image_list | grep -c . )
mkdir -p "$OUT" || exit 1
LOG="$OUT/_failed.txt"
: > "$LOG"

echo "Regent Products - cat christmas (dog overlap removed)"
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
