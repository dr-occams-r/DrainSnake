// Drain Snake
//   TPU Flexible to make sure it doesn't break down drain
//   Many small hooks
//   Thicker body to keep it's shape when printing in TPU
//   Body much thicker than hooks to ensure that hooks
//     would break before body if ever stuck on a hook
//     down the drain
//   Easy to print
//   Handle Hook to hang and dry
//   Handle Ring to pull

// Print Notes:
//   TPU
//   0.4mm Nozzle, 0.2mm Height, First Layer Width 0.5mm
//   Infill 100%
//   Lines: 3 Perimeter

// Prerequisite:
//   BOSL2 https://github.com/BelfrySCAD
include <BOSL2-local/std.scad>


/* [Snake Body] */
Notes              = "";
SnakeLength        = 150; // [0:1:300]
SnakeWidth         = 3;  // [0:0.1:50]
// Core body thicker or else too floppy with TPU.
BodyThickness      = 3;  // [0:0.1:50]

/* [Spikes] */
SpikeWidth         = 3;  // [0:1:50]
SpikeProtrude      = 2;  // [0:0.1:50]
// Will grab easier if spikes are thin
SpikeBaseThickness = 3;  // [0:0.1:50]
SpikeAngle         = 45; // [0:1:90]
SpikeGap           = 1;  // [0:1:50]

/* [Handle] */
HandleNeckLength   = 0; // [0:1:300]
RingWidth          = 3;  // [0:1:50]
// Ring Inner Diameter
RingDiameterOuter  = 50;  // [0:1:100]
RingOpeningAngle   = 30;  // [0:1:180]

/* [General] */
VeryThin = 0.001; //[0:0.0001:2]

/* [Finalization] */
Smooth = true;
FragmentsSmooth = 100; // 5:1:1000
FragmentsRegular = 10; // 5:1:1000
fnCalc = Smooth ? FragmentsSmooth : FragmentsRegular;
$fn = fnCalc;

// Prep Calculations
SnakeWidthHalf = SnakeWidth / 2;
SpikeRatio = tan(SpikeAngle);

// Body
SnakeTipChamfer = SnakeWidthHalf - VeryThin;

// Spikes
SpikeOffset = SpikeRatio * SpikeProtrude;
SpikesLeft = SnakeLength - SnakeTipChamfer;
SpikeSpan = SpikeWidth + SpikeOffset;
SpikeSpanDouble = SpikeSpan * 2;
// Keep spikes from going into handle area
SpikesLength = SpikesLeft - SpikeSpanDouble;
SpikesSpacing = SpikeWidth + SpikeGap;
SpikesSpacingHalf = SpikesSpacing / 2;
SpikesOffset = SpikesSpacingHalf;

// Handle
HandleWidth = SnakeWidth;
RingWidthHalf = RingWidth / 2;
RingRadiusOuter = RingDiameterOuter / 2;
//RingRight = SpikesSpacing + RingRadiusOuter + HandleNeckLength;
RingRight = RingRadiusOuter + HandleNeckLength;
RingRadiusInner = RingRadiusOuter - RingWidth;
HandleLengthFull = HandleNeckLength + RingDiameterOuter - RingWidthHalf;
RingAngleStart = -180 + RingOpeningAngle;
// +0 Calculation to keep it out of customizer parameters
RingAngleEnd = 180 + 0;

FinalLength = SnakeLength + HandleLengthFull;
echo("FinalLength:", FinalLength);

module SnakeBody(){
  cuboid(
    size=[SnakeLength, SnakeWidth, BodyThickness],
    chamfer=SnakeTipChamfer,
    edges=[LEFT+FWD,LEFT+BACK],
    anchor=BOT+RIGHT
  );
}
//Body();

module Spike(){
  right(SpikeWidth){
    fwd(SnakeWidthHalf){
      hull(){
        // Spike Base
        cuboid(
          [SpikeWidth, VeryThin, SpikeBaseThickness],
          anchor=BOT+FWD+RIGHT
        );
        // Spike Tip
        right(SpikeOffset){
          fwd(SpikeProtrude){
            cuboid(
              [VeryThin, VeryThin, VeryThin],
              anchor=BOT+FWD+RIGHT
            );
          }
        }
      }
    }
  }
}
//Spike();

module SpikesHalf(){
  left(SpikesLeft){
    xcopies(
      l=SpikesLength,
      spacing=SpikesSpacing,
      sp=[0,0,0]
    ){
      Spike();
    }
  }
}
//SpikesHalf();

module Spikes(){
  right(SpikesOffset){
    SpikesHalf();
  }
  yflip(){
    SpikesHalf();
  }
}

module HandleBody(){
  cuboid(
    size=[HandleLengthFull, HandleWidth, BodyThickness],
    anchor=BOT+LEFT
  );
}

module Ring(){
  right(RingRight){
    linear_extrude(BodyThickness){
      ring(
        ring_width=RingWidth,
        r=RingRadiusInner,
        angle=[RingAngleStart,RingAngleEnd]
      );
    }
  }
}
Ring();

module Snake(){
  SnakeBody();
  Spikes();
  HandleBody();
}

Snake();

