/*
Notes and TODO:
- Add supports under seat itself
- Arm rests?
*/

// all units are in inches
// material & tool constraints
board_length = 48.5*2;
board_width = 24.5*2;
board_depth = 0.484;
tool_diameter = 0.1875;     // 3/16

// circle precision
$fn = 90;

// project variables
chair_width = 17.5;
seat_height = 17.5;
back_height = 16;
seat_length = 15.5;
back_depth_max = 1;

// individual variables
foot_width = 2;
indent = 5;             // distance from y axis to middle of top of leg 1
leg_width_max = 4;      // maximum leg width (width at top of leg)
middle_bar_width = 3;   // width of middle bar that holds the seat

// offset/rounding and chambfer vars
legs_offset_round = 0.5;
tab_offset = 0.02;
joinner_offset = 0.01;

// tab variables
seat_tab_length = 2;
seat_tab_number = 5;
back_tab_number = 4;
back_tab_length = 2;

// joinner variables
leg_joinner_height = 2;
middle_joinner_height = 3;
middle_joinner_width = 5;
leg_joinner_width = 3;
joinner_extend = 2;

// dont change these variables (legacy variables)
back_width = chair_width;
seat_width = chair_width;

module Tab (arg_length, arg_height = board_depth) {
    // module for creating tabs to attach boards
    difference() {
        //offset(r = -tab_offset)
        cube([board_depth, arg_length, arg_height]);
        translate([-1,0,tool_diameter/2])
        rotate([0,90,0])
        cylinder( d=tool_diameter, h = board_depth+2);
        translate([-1,arg_length,tool_diameter/2])
        rotate([0,90,0])
        cylinder( d=tool_diameter, h = board_depth+2);
    }
}

module Seat () {
    adjusted_tab_length = seat_tab_length-tab_offset;
    union() {
        linear_extrude(height = board_depth)
        square([seat_length, seat_width]);
        for (o = [0:seat_tab_number-1]) {     // o is number of seat tab
            // closer side
            translate([
                (o/(seat_tab_number-1))*
                (seat_length-adjusted_tab_length-tab_offset)+
                adjusted_tab_length,
                0,
                0
            ]) {
                rotate([90,-90,00])
                Tab(adjusted_tab_length, board_depth);
                // far side
                translate([0,seat_width,board_depth])
                rotate([-90,90,00])
                Tab(adjusted_tab_length, board_depth);
            }
        }
    }
}

module Leg () {
    // offset is to add rounded corners etc.
    //echo("Full width: ", indent+seat_length+leg_width_max/2+legs_offset_round*2);
    difference() {
        // actual Leg
        linear_extrude( height = board_depth )
        offset( r= legs_offset_round)
        polygon ( 
            points = [
                // back foot
                [0,0], 
                [foot_width, 0], 
                // underside of seat
                // back inner corner under seat
                [indent+leg_width_max/2, 
                    seat_height-middle_bar_width/2],
                // front inner corner under seat
                [indent+seat_length-leg_width_max/2, 
                    seat_height-middle_bar_width/2],
                // front foot
                [indent+seat_length, 0],
                [indent+seat_length+foot_width, 0],
                // front leg
                [indent+seat_length+leg_width_max/2, 
                    seat_height+middle_bar_width/2],
                // seat top
                [indent+leg_width_max/2, seat_height+middle_bar_width/2],
                // bit at top of back
                [back_depth_max, seat_height+back_height+middle_bar_width/2],
                [0, seat_height+back_height+middle_bar_width/2], 
                // indent in back
                [indent-leg_width_max/2, seat_height+middle_bar_width/2],
                [indent-leg_width_max/2, seat_height-middle_bar_width/2],
                // implicitly returns to point 0
            ], paths = [
                [0,1,2,3,4,5,6,7,8,9,10,11],
            ], convexity = 10   // 10 is a good value i guess?
        );
        // Removed Part...
        // Seat tabs
        translate([indent+leg_width_max/2, seat_height, -board_depth]) {
            for (o = [0:seat_tab_number-1]) {     // o is number of seat tab
                translate([
                    (o/(seat_tab_number-1))*
                    (seat_length-seat_tab_length)+
                    seat_tab_length,
                    0,
                    0
                ])
                rotate([0,0,90])
                Tab(seat_tab_length, board_depth*3);
                
                translate([
                    (o/(seat_tab_number-1))*
                    (seat_length-seat_tab_length)+
                    seat_tab_length,
                    -board_depth-tab_offset,
                    0
                ])
                rotate([0,0,90])
                Tab(seat_tab_length, board_depth*3);
                
                translate([
                    (o/(seat_tab_number-1))*
                    (seat_length-seat_tab_length)+
                    seat_tab_length,
                    -board_depth/2,
                    0
                ])
                rotate([0,0,90])
                Tab(seat_tab_length, board_depth*3);
            }
        }
        // Back Tabs
        translate([
            indent, 
            seat_height+middle_bar_width, 
            -board_depth
        ]) 
        rotate([0,0, 180-atan(back_height/indent)]){
            for (o = [0:back_tab_number-1]) {     // o is number of back tab
                translate([
                    (o/(back_tab_number-1))*
                    (back_height-back_tab_length-middle_bar_width/2)+
                    back_tab_length,
                    0,
                    0
                ])
                rotate([0,0,90])
                Tab(back_tab_length, board_depth*3);
            }
        }
        // Joinners
        translate([foot_width/2,leg_joinner_height-legs_offset_round,-1]) {
            cube([
                joinner_offset+board_depth, 
                leg_joinner_width+joinner_offset, 
                10
            ]);
            translate([seat_length+indent, 0,0])
            cube([
                joinner_offset+board_depth, 
                leg_joinner_width+joinner_offset, 
                10
            ]);
            // middle one
            translate([
                indent-foot_width/2, 
                seat_height-middle_bar_width-middle_joinner_width/2,
                0
            ])
            cube([
                joinner_offset+board_depth, 
                middle_joinner_width+joinner_offset, 
                10
            ]);
        }
    }
}

module Back () {
    adjusted_tab_length = back_tab_length-tab_offset;
    union() {
        linear_extrude(height = board_depth)
        square([back_height, back_width]);
        for (o = [0:back_tab_number-1]) {     // o is number of seat tab
            // closer side
            translate([
                (o/(back_tab_number-1))*
                (back_height-adjusted_tab_length-tab_offset-middle_bar_width/2)+
                adjusted_tab_length,
                0,
                0
            ]) {
                rotate([90,-90,00])
                Tab(adjusted_tab_length, board_depth);
                // far side
                translate([0,back_width,board_depth])
                rotate([-90,90,00])
                Tab(adjusted_tab_length, board_depth);
            }
        }
    }
}

module Chair () {
    color("Aquamarine")
    rotate([90,0,0])
    Leg();
    color("Red")
    translate([0,seat_width+board_depth,0])
    rotate([90,0,0])
    Leg();
    
    color("RoyalBlue")
    translate([indent+leg_width_max/2+tab_offset/2, 0, seat_height])
    Seat();
    
    color("MidnightBlue")
    translate([indent+leg_width_max/2+tab_offset/2, 0, seat_height-board_depth - tab_offset/2])
    Seat();
    
    color("SteelBlue")
    translate([indent, 0, seat_height+middle_bar_width])
    rotate([0,180+atan(back_height/indent),0])
    Back();
    
    color("CadetBlue")
    translate([
        board_depth+foot_width/2,
        -board_depth*3,
        -legs_offset_round
    ])
    rotate([0,-90,0])
    JoinnerSide(
        chair_width+joinner_extend+board_depth*2, 
        leg_joinner_width, 
        chair_width+board_depth*2, 
        leg_joinner_height
    );
    
    color("SkyBlue")
    translate([
        seat_length+indent+board_depth+foot_width/2,
        -board_depth*3,
        -legs_offset_round
    ])
    rotate([0,-90,0])
    JoinnerSide(
        chair_width+joinner_extend+board_depth*2, 
        leg_joinner_width, 
        chair_width+board_depth*2, 
        leg_joinner_height
    );
    
    //color("Aqua")
    translate([
        indent+board_depth,
        -board_depth*3,
        seat_height-board_depth-middle_joinner_height*2
    ])
    rotate([0,-90,0])
    JoinnerSide(
        chair_width+joinner_extend+board_depth*2, 
        middle_joinner_width, 
        chair_width+board_depth*2, 
        middle_joinner_height
    );
}

module JoinnerSide (
    arg_length, 
    arg_width, 
    arg_internal_length, 
    arg_internal_width
) {
    difference() {
        cube([arg_width-joinner_offset, arg_length, board_depth]);
        translate([-0.1,(arg_length-arg_internal_length)/2, -0.1]) {
            cube([
                arg_internal_width+0.2, 
                board_depth+joinner_offset, 
                board_depth+0.2
            ]);
            translate([0.1+arg_internal_width,0,0])
            cylinder(h = board_depth+0.2, d = tool_diameter);
            translate([0.1+arg_internal_width,board_depth+joinner_offset,0])
            cylinder(h = board_depth+0.2, d = tool_diameter);
        }
        translate([
            -0.1,
            arg_length-(arg_length-arg_internal_length)/2-
                (board_depth+joinner_offset), 
            -0.1
        ]) {
            cube([
                arg_internal_width+0.2, 
                board_depth+joinner_offset, 
                board_depth+0.2
            ]);
            translate([0.1+arg_internal_width,0,0])
            cylinder(h = board_depth+0.2, d = tool_diameter);
            translate([0.1+arg_internal_width,board_depth+joinner_offset,0])
            cylinder(h = board_depth+0.2, d = tool_diameter);
        }
    }
}



module Layout() {
    projection(cut = false) {
        for (a= [1:2]) {
            translate([a*40, 0,0])
            Leg();
            translate([a*40, 40, 0])
            JoinnerSide(
                chair_width+joinner_extend+board_depth*2, 
                leg_joinner_width, 
                chair_width+board_depth*2, 
                leg_joinner_height
            );
        }
        translate([120,0,0])
        Seat();
        translate([160,40,0])
        Seat();
        translate([160,0,0])
        Back();
        translate([3*40, 40, 0])
        JoinnerSide(
            chair_width+joinner_extend+board_depth*2, 
            middle_joinner_width, 
            chair_width+board_depth*2, 
            middle_joinner_height
        );
    }
    
}
//rotate([$t*360,$t*360,$t*360])
Chair();
//Seat();
//Leg();
//Back();
//rotate([0,0,90])
//Tab();
//JoinnerSide(chair_width+2, 3, chair_width, 2);
//Layout();