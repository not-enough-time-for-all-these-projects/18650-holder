include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>

// count
numBatteries = 1;

// BatteryDimensions
// https://en.wikipedia.org/wiki/List_of_battery_sizes#Cylindrical_lithium-ion_rechargeable_battery
//18650
batteryDiameter = 18;
batteryLength = 65+1;

// variables
wallThick = 3.5;
batterySpacer = wallThick/4;
EPS=0.1;

boxWidth = (batteryDiameter + 2* batterySpacer) * numBatteries + batterySpacer * 2;
boxLength = batteryLength+ 2*(wallThick);
boxHeight = batteryDiameter / 2.0;

contactWidth = 10;
contactHeight = 20;
contactThick  = 0.35; 
springWidth = 5;
springSlot = 1;

$fn=120;

module contact() {
  cube([springWidth+EPS, contactHeight, springSlot]);
  translate([-springWidth/2,0,contactThick*2]) {
      cube([contactWidth, contactHeight, springSlot]);
  }
}

module outerWalls() {
  // outer walls
  thick=wallThick;

  difference() {
    cube([boxWidth, thick, batteryDiameter]);
    up(batteryDiameter) rotate([90, 0, 0]) {
      fillet_mask_z(l=thick, r=batteryDiameter/2, align=V_DOWN);
      right(boxWidth) fillet_mask_z(l=thick, r=batteryDiameter/2, align=V_DOWN);

    }
    translate([boxWidth/2-springWidth/2, wallThick, 0]) {
      rotate([90, 0, 0]) contact();
    }    
  }

  translate([0, boxLength-wallThick, 0]) {
    difference() {
      cube([boxWidth, thick, batteryDiameter]);
      up(batteryDiameter) rotate([90, 0, 0]) {
        fillet_mask_z(l=thick, r=batteryDiameter/2, align=V_DOWN);
        right(boxWidth) fillet_mask_z(l=thick, r=batteryDiameter/2, align=V_DOWN);

      }
      translate([(boxWidth)/2+springWidth/2, 0, 0]) {
        rotate([90, 0, 180]) contact();     
      }
    }
  }
}
    
module BatteryHolder() {
  difference() {
    // baseplate
    cube([boxWidth, boxLength, boxHeight]); 

    // battery cutout
    for (i=[0:numBatteries-1]) {
      translate([i * (batteryDiameter+2*batterySpacer) + batteryDiameter/2+batterySpacer*2, boxLength ,batteryDiameter/2+wallThick]) {
        rotate([90, 0, 0]) {
          cylinder(h=boxLength,d=batteryDiameter);     
        }              
      }
    }
  }
  for (i=[0:numBatteries-1]) {
    translate([0, 0, 0]) {
      outerWalls();
    }
  }
}

BatteryHolder();
