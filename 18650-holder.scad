include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>
use <MCAD/nuts_and_bolts.scad>

// count of cells
numBatteries = 1;

// BatteryDimensions
// https://en.wikipedia.org/wiki/List_of_battery_sizes#Cylindrical_lithium-ion_rechargeable_battery
// 18650
batteryDiameter = 18;
batteryLength = 65+1;

// variables
wallThick = 3.5;
batterySpacer = wallThick/4;
EPS=0.1;

boxWidth = (batteryDiameter + 2* batterySpacer) * numBatteries + batterySpacer * 2;
boxLength = batteryLength+ 2*(wallThick);
boxHeight = batteryDiameter / 2.0;

contactWidth         = 10.2;
contactHeight        =  9.2;
contactThick         =  1.2;
contactSpringWidth   =  6.4;
contactSlot          =  .6;
contactContactWidth  =  3.2;
contactContactLength =  7;

bracketCubeSize=8;

$fn=120;

module _contactslot() {
  translate([0, 0, contactSlot]) {
    // plate
    cube([contactWidth, contactHeight, contactThick]);
    // slot 
    cube([contactWidth, contactHeight+boxHeight, contactThick]);
    // spring
    translate([(contactWidth-contactSpringWidth)/2, 0, -contactSlot]) {
      cube([contactSpringWidth, contactHeight+boxHeight, contactSlot]);
    }
    // Contact for the plug
    translate([(contactWidth-contactContactWidth)/2,-contactContactLength,0]) {
      cube(size=[contactContactWidth, contactContactLength, contactThick]);
    }
  }
  // cube([springWidth+EPS, contactHeight, springSlot]);
  // translate([-springWidth/2,0,contactThick*2]) {
  //     cube([contactWidth, contactHeight, springSlot]);
  // }
}

module contactslots() {
    translate([-wallThick-contactThick/2, /*wallThick*/0, 0]) {
      translate([batteryDiameter/2-wallThick, wallThick, boxHeight/2]) {
        rotate([90, 0, 0]) _contactslot();
      }
    }
    translate([wallThick*2-contactThick, (boxLength-wallThick), 0]) {
      translate([batteryDiameter/2-wallThick, 0, boxHeight/2]) {
        rotate([90, 0, 180]) _contactslot();     
      }
    }
}

module _boltBracket() {
  screwElevation=1.2;
  difference() {
    cube(size=[bracketCubeSize, bracketCubeSize, bracketCubeSize/2]);
    up(bracketCubeSize) {
      fillet_mask_z(l=bracketCubeSize, r=bracketCubeSize/2, align=V_DOWN);
      back(bracketCubeSize) fillet_mask_z(l=bracketCubeSize, r=bracketCubeSize/2, align=V_DOWN);
    }
    translate([bracketCubeSize/2, bracketCubeSize/2, screwElevation]) {
      rotate([0, 180, 0]) {
      boltHole(size=3, length=5);   
    }
  }

  }
}

module boltBrackets() {
  // screwHoles
  translate([-bracketCubeSize,0,0]) {
    _boltBracket();
  }
  translate([-bracketCubeSize,boxLength-bracketCubeSize,0]) {
    _boltBracket();
  }
  translate([boxWidth, boxLength, 0]) {
    rotate([180,180,0]) {
      translate([-bracketCubeSize,0,0]) {
        _boltBracket();
      }
      translate([-bracketCubeSize,boxLength-bracketCubeSize,0]) {
        _boltBracket();
      }
    }
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
  }

  translate([0, boxLength-wallThick, 0]) {
    difference() {
      cube([boxWidth, thick, batteryDiameter]);
      up(batteryDiameter) rotate([90, 0, 0]) {
        fillet_mask_z(l=thick, r=batteryDiameter/2, align=V_DOWN);
        right(boxWidth) fillet_mask_z(l=thick, r=batteryDiameter/2, align=V_DOWN);
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
      translate([i * (batteryDiameter+2*batterySpacer) + batteryDiameter/2+batterySpacer*2, boxLength ,batteryDiameter/2+wallThick /* should be boxHeight */]) {
        rotate([90, 0, 0]) {
          cylinder(h=boxLength,d=batteryDiameter);     
        }              
      }
    }
  } //difference basePlate
  outerWalls();
  boltBrackets();
}

difference() {
  BatteryHolder();
  // cut out contact slots
  for (i=[0:numBatteries-1]) {
    translate([i*(batteryDiameter+batterySpacer*2)+(batteryDiameter-contactWidth)/2, 0, 0]) {
      contactslots();
    }
  }
}