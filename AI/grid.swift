//
//  grid.swift
//  AI
//
//  Created by Chikao Maeda on 5/31/18.
//  Copyright © 2018 Chikao Maeda. All rights reserved.
//

import Foundation

//
//import pygame as py
//import random as r
//import math
//from heursitic import A_Star_Seq
//from heursitic import GraphSearch
//from heursitic import Vertex
//import sys
//import time
//import copy
//import json
//from ast import literal_eval as make_tuple

//"""
//
//In terms of funcining costs, if we are starting from a cell that contains a highway and we are
//moving horizontally|| vertically into a cell that also contains a highway, the cost of this motion
//is four times less than it would be otherwise (i.e., 0.25 if both cells are regular, 0.5 if both cells
//are hard to traverse and 0.375 if we are moving between a regular unblocked cell and a hard to
//traverse cell).
//"""

var collision = false

//"""
//If you cannot
//add a highway given the placement of the previous rivers, start the process from the beginning.
//"""

let adjust = 1
let STEP_SIZE = 100

let TOTAL_ROWS = 120/adjust
let TOTAL_COLS = 160/adjust

var grid = Array(repeating: Array(repeating: "0", count: TOTAL_COLS), count: TOTAL_ROWS)


let START_ROW_TOP_MIN = 0
let START_ROW_TOP_MAX = 19/adjust
let START_ROW_BOT_MIN = 99/adjust
let START_ROW_BOT_MAX = 119/adjust

let START_COL_LEFT_MIN = 0
let START_COL_LEFT_MAX = 19/adjust
let START_COL_RGHT_MIN = 139/adjust
let START_COL_RGHT_MAX = 159/adjust

let GOAL_ROW_TOP_MIN = 0
let GOAL_ROW_TOP_MAX = 19/adjust
let GOAL_ROW_BOT_MIN = 99/adjust
let GOAL_ROW_BOT_MAX = 119/adjust

let GOAL_COL_LEFT_MIN = 0
let GOAL_COL_LEFT_MAX = 19/adjust
let GOAL_COL_RGHT_MIN = 139/adjust
let GOAL_COL_RGHT_MAX = 159/adjust

let RIVER_INCREMENT = 20/adjust

let DISTANCE_MIN = 100/adjust

let RIVER_MIN = 100/adjust

let HARD_DIM = 32/adjust

let BLOCKED_TOTAL = TOTAL_ROWS*TOTAL_COLS/5

func pathVisual(path: [(Float, Vertex)]){
    for cord in path{
        let row = cord.1.row
        let col = cord.1.col
        grid[row][col] = "r"
    }
}



func random(_ n: Int) -> Int
{
    return Int(arc4random_uniform(UInt32(n)) + 0)
}

func randomProb() -> Double{
    return Double((arc4random_uniform(100) + 0))/100.0
}

func setStart() -> ((Int, Int)){
//top 20 rows|| bottom 20 rows
    var row = random(START_ROW_TOP_MAX)
    if randomProb() <= 0.5{
        row = random(START_ROW_TOP_MIN)
    }
//left most 20|| right most 20 columns
    var col = random(START_COL_LEFT_MAX)
    if randomProb() <= 0.5{
        col = random(START_COL_RGHT_MAX)
    }
    grid[row][col] = "r"
    return (row, col)
}
//
//func getsetStart(){
//    #top 20 rows|| bottom 20 rows
//    row = r.randint(START_ROW_TOP_MIN, START_ROW_TOP_MAX)
//    if randomProb() <= 0.5{
//    row = r.randint(START_ROW_BOT_MIN, START_ROW_BOT_MIN)
//    #left most 20|| right most 20 columns
//    col = r.randint(START_COL_LEFT_MIN, START_COL_LEFT_MAX)
//    if randomProb() <= 0.5{
//    col = r.randint(START_COL_RGHT_MIN, START_COL_RGHT_MAX)
//    return (row, col)

func setGoal(start: (Int, Int))->((Int, Int)){
    var row = 0
    var col = 0
    var distance = 0.0
    while(distance < DISTANCE_MIN){
        //top 20 rows|| bottom 20 rows
        row = random(GOAL_ROW_TOP_MAX)
        if randomProb() <= 0.5{
            row = random(GOAL_ROW_BOT_MIN)
        }
        //left most 20|| right most 20 columns
        col = random(GOAL_COL_LEFT_MAX)
        if randomProb() <= 0.5{
            col = random(GOAL_COL_RGHT_MAX)
            distance = sqrt(Double(pow(Decimal(row - start.0), 2) + pow(Decimal(col - start.1), 2)))
        }
    }
    grid[row][col] = "r"
    return (row,col)
}
//func getsetGoal(grid, start){
//    row = 0
//    col = 0
//    distance = 0
//    while(distance < DISTANCE_MIN){
//    #top 20 rows|| bottom 20 rows
//    row = r.randint(GOAL_ROW_TOP_MIN, GOAL_ROW_TOP_MAX)
//    if randomProb() <= 0.5{
//    row = r.randint(GOAL_ROW_BOT_MIN, GOAL_ROW_BOT_MIN)
//    #left most 20|| right most 20 columns
//    col = r.randint(GOAL_COL_LEFT_MIN, GOAL_COL_LEFT_MAX)
//    if randomProb() <= 0.5{
//    col = r.randint(GOAL_COL_RGHT_MIN, GOAL_COL_RGHT_MAX)
//    distance = math.sqrt(math.pow(row - start[0], 2) + math.pow(col- start[1], 2))
//    return (row,col)

func reset(_ rlist: [(Int, Int)]){
    var rlist = rlist
    for cord in rlist{
        let row = cord.0
        let col = cord.0
        grid[row][col] = "1"
        rlist.removeAll()
    }
}
func DIRS(_ input: String) -> ((Int, Int)){
    switch(input){
        case "up": return (-1, 0)
        case "down": return (1, 0)
        case "left":  return (0, -1)
        case "right": return (0, 1)
        default: return (0,0)
    }
}

func directions(_ direction: String,_ row: Int,_ col: Int,_ rlist: [(Int, Int)]){
    var direction = direction
//    var global collision
    //#print("start")
    //#print(row, col)
//    """
//    Continue marking cells in this manner, until you hit the boundary again.
//    """
    if(row >= TOTAL_ROWS || col >= TOTAL_COLS || row < 0 || col < 0){
    //#print("return 25")
        return nil
    }
    
    var dir = DIRS[direction]
    var dir_i = dir.0
    var dir_j = dir.1
    for i in 0 ... RIVER_INCREMENT{
        if(row < 0 || row >= TOTAL_ROWS){
            return nil
        }
        if(col < 0 || col >= TOTAL_COLS){
            return nil
        }
        //"""
        //If you hit a cell that is already a highway in this process, reject the path and start the process again.
        //"""

        if(grid[row][col] == "a" || grid[row][col] == "b"){
            collision = true
            return nil
        }
        if grid[row][col] == "1"{
            grid[row][col] = "a"
        }
        if grid[row][col] == "2"{
            grid[row][col] = "b"
        }
        rlist.append([row, col])

        if dir_i != 0{
            row += dir_i
        }
        if dir_j != 0{
            col += dir_j
        }
    }
    if dir_i != 0{
        row -= dir_i
    }
    if dir_j != 0{
        col -= dir_j
    }
    
    //"""
    //To continue, with 60% probability select to move in the same direction
    //and 20% probability select to move in a perpendicular direction (turn the highway left|| turn the
    //highway right).
    //"""
    if randomProb() <= 0.6{
        return directions(direction, row+dir_i, col+dir_j, rlist)
    }else{
        if(direction == "right" || direction == "left"){
            if randomProb() <= 0.5{
                direction = "up"
            }else{
                direction = "down"
            }
        }else{
            if randomProb() <= 0.5{
                direction = "right"
            }else{
                direction = "left"
                dir_i, dir_j = DIRS[direction]
                
            }
        }
    }
    return directions(direction, row+dir_i, col+dir_j, rlist)
}


func river(start: Int, grid: [[String]], rlist: [(Int, Int)]){
    var row = 0
    var col = 0
    if randomProb() <= 0.5{
        row = start
    }else{
        col = start
    }
//    """
//    Then, move in a random horizontalor vertical direction for 20 cells
//    but away from the boundary and mark this sequence of cells as
//    containing a highway.
//    """
    if row == start{
        if randomProb() <= 0.5{
            col = 0
            directions("right", row, col, rlist)
        }
        else{
            col = (grid[0]).count - 1
            directions("left", row, col, rlist)
        }
    }
    if col == start{
        if randomProb() <= 0.5{
            row = 0
            directions("down", row, col, rlist)
        }
        else{
            row = (grid).count - 1
            directions("up", row, col, rlist)
        }
    }
    }

func riverTest(start: Int, grid: [[String]], rlist: [(Int, Int)])){
    while(rlist.count < RIVER_MIN){
        river(start: start, grid: grid, rlist: rlist)
//        """
//        If the length of the path is less than 100
//        cells when you hit the boundary, then reject the path and start the process again.
//        """
        if rlist.count < RIVER_MIN || collision == true{
            reset(rlist)
//            rlist = []
            start = random(0, TOTAL_COLS)
            collision = false
        }
    }
}

func hardTraverse(row: Int, col: Int, grid: [[String]){
    var count = 2
    if row >= TOTAL_ROWS || col >= TOTAL_COLS || row < 0 || col < 0{
        return
    }
    grid[row][col] = "2"
    direction = "right"
    dir_i, dir_j = DIRS[direction]
    while count < HARD_DIM*HARD_DIM{
        if row >= TOTAL_ROWS || col >= TOTAL_COLS || row < 0 || col < 0{
            return
        }
        if randomProb() <= 0.5{
            grid[row][col] = "2"
        }
        dir_i, dir_j = DIRS[direction]
        n = count - 1
        n_sqrt = int(sqrt(n))
        if pow(n_sqrt, 2) + 1 == count{
            if count%2 == 1{
                direction = "up"
            }
            else{
                direction = "down"
            }
        }
        if math.pow(n_sqrt, 2) + n_sqrt+ 1 == count{
            if n_sqrt%2 == 1{
                direction = "left"
            }
            else{
                direction = "right"
            }
        }
        row += dir_i
        col += dir_j
        count += 1
    }
}

    

func blocked(grid: [[String]]){
    num_blocks = BLOCKED_TOTAL
    while num_blocks > 0{
        for row in range(TOTAL_ROWS){
            for col in range(TOTAL_COLS){
                if num_blocks == 0{
                    break
                }
                if(randomProb() < 0.2 && grid[row][col] == "1"){
                    grid[row][col] = "0"
                    num_blocks -= 1
                }
            }
        }
    }
}

//funcine some colors
//BLACK = (0, 0, 0)
//WHITE = (255, 255, 255)
//BLUE = (0, 0, 255)
//RED = (255, 0, 0)
//GREEN = (0, 255, 0)
//ORANGE = (255, 165, 0)
//
//DARK_WHITE = (107,107,107)
//DARK_BLUE = (0, 0, 110)
//DARK_ORANGE = (150, 100, 0)
//DARK_GREEN = (0,110,0)


//WIDTH = 5*adjust
//HEIGHT = 5*adjust
//
////This sets the margin between each cell
//MARGIN = 1*adjust


func fillGrid()->([[String]]){
    var grid = [[String]]
    
    for row in 0... TOTAL_ROWS){
        grid.append([])
        for col in range(TOTAL_COLS){
            grid[row].append("1")
        }
    }
            list_hard = []
            for i in range(8){
                row_hard = r.randint(0, TOTAL_ROWS)
                col_hard = r.randint(0, TOTAL_COLS)
                list_hard.append((row_hard, col_hard))
                hardTraverse(row_hard, col_hard, grid)
            }
                
                
            r1_list = []
            r2_list = []
            r3_list = []
            r4_list = []
            
            r1 = r.randint(0, TOTAL_COLS)
            r2 = r.randint(0, TOTAL_COLS)
            r3 = r.randint(0, TOTAL_COLS)
            r4 = r.randint(0, TOTAL_COLS)
            
            //print("r1")
            riverTest(r1, grid, r1_list)
            //print("r2")
            riverTest(r2, grid, r2_list)
            //print("r3")
            riverTest(r2, grid, r3_list)
            //print("r4")
            riverTest(r2, grid, r4_list)
            //
            //#Make Blocked cells
            blocked(grid)
            
            //with open("output.txt", "w") as outfile{
            //    json.dump(grid, outfile)
            
            pathStart = setStart(grid)
            pathGoal = setGoal(grid, pathStart)
}



//list_hard = []
//for i in range(8){
//row_hard = r.randint(0, TOTAL_ROWS)
//col_hard = r.randint(0, TOTAL_COLS)
//list_hard.append((row_hard, col_hard))
//hardTraverse(row_hard, col_hard, grid)
//
//
//r1_list = []
//r2_list = []
//r3_list = []
//r4_list = []
//
//r1 = r.randint(0, TOTAL_COLS)
//r2 = r.randint(0, TOTAL_COLS)
//r3 = r.randint(0, TOTAL_COLS)
//r4 = r.randint(0, TOTAL_COLS)
//
////print("r1")
//riverTest(r1, grid, r1_list)
////print("r2")
//riverTest(r2, grid, r2_list)
////print("r3")
//riverTest(r2, grid, r3_list)
////print("r4")
//riverTest(r2, grid, r4_list)
////
////#Make Blocked cells
//blocked(grid)
//
////with open("output.txt", "w") as outfile{
////    json.dump(grid, outfile)
//
//pathStart = setStart(grid)
//pathGoal = setGoal(grid, pathStart)

//#print(pathStart)
//#print(pathGoal)

//choice = input("save grid|| load grid\n")

//if choice == "save"{
//    file = open("output.txt","w")

//    file.write(str(pathStart)+"\n")
//    file.write(str(pathGoal)+"\n")
//    file.write(str(list_hard)+"\n")
//    file.write("[")
//    for i in range(TOTAL_ROWS){
//        file.write("[")
//        for j in range(TOTAL_COLS){
//            file.write(grid[i][j])
//            if(j < TOTAL_COLS - 1){
//                file.write(",")
//        file.write("]")
//        if(i < TOTAL_ROWS - 1){
//            file.write(",\n")
//    file.write("]")
//    file.close()
//    sys.exit("map loaded")

//if choice == "load"{
//    file = open("output.txt", "r")
//    lines = file.readlines()
//    newGrid = []
//    print(make_tuple(lines[0]))
//    print(make_tuple(lines[1]))
//    print(lines[2])
//    for i in range(3, TOTAL_ROWS + 3){
//        newGrid.append([])
//        newGrid[i-3] = lines[i].replace("[", "").replace("]", "").split(",")
//        if i < TOTAL_ROWS + 2{
//            newGrid[i-3].pop()
//    grid = newGrid
//    #pathStart = setStart(grid)
//    #pathGoal = setGoal(grid,pathStart)
//    print(grid)
//#print(pathStart)
//#print(pathGoal)

print(pathStart)
print(pathGoal)
input_graph = input("Input graph type{ ")

graph_select = {
    "d"{ "Dijkstra",
    "a"{ "A*",
    "w"{ "Weighted A*",
    "s"{ "Sequential A*",
}

graph_type = graph_select[input_graph]
print(graph_type)

input_weight = 0.0
if input_graph == "d"{
input_weight = 0.0
if input_graph == "a"{
input_weight = 1.0
if input_graph == "w"{
input_weight = input("Input Weight{ ")
input_weight1 = 0
input_weight2 = 0
if input_graph == "s" {
input_weight1 = input("Input Weight1{ ")
input_weight2 = input("Input Weight2{ ")



print "Your input weight is " + str(input_weight)

heursitic_input = 0

if input_graph == "a"|| input_graph == "w"{
heursitic_input = input("Select heursitic{ ")

HEURISTIC_MAP = {
    0{ "You have selected consistant heuristic",
    1{ "You have selected diagnol distance",
    2{ "You have selected euclidean distance",
    3{ "You have selected given heuristic",
    4{ "You have selected manhattan distance",
}

print(HEURISTIC_MAP[heursitic_input])


graph_heuristic = {
    "d"{ 0,
    "a"{ "A*",
    "w"{ "Weighted A*",
    "s"{ "Sequential A*",
}

        

searcher = GraphSearch(copy.deepcopy(grid))
seq_searcher = A_Star_Seq(copy.deepcopy(grid), input_weight1, input_weight2)




//#############################################
//py.init()
//
////Set the HEIGHT and WIDTH of the screen
//WINDOW_SIZE = [1200, 750]
//screen = py.display.set_mode(WINDOW_SIZE)
//
////Set title of screen
//py.display.set_caption("A*")
//
////Loop until the user clicks the close button.
//done = False
//
////Used to manage how fast the screen updates
//clock = py.time.Clock()
//
////initialize font; must be called after "pygame.init()" to avoid "Font not Initialized" error
//myfont = py.font.SysFont("arial", 25)
//
////render text
//label = myfont.render("0", 1, BLACK)
//screen.blit(label, (row, col))
//
//path = nil
//pq = nil
//
//
//click_grid = ""
//click_g = ""
//click_h = ""
//click_f = ""
//time_result = ""
//g_result = ""
//h_result = ""
//f_result = ""
//nodes = ""
//
//start_time = time.time()
//first = False
//grid = searcher.grid
//second = False
//firstTime = True
//////-------- Main Program Loop -----------
//while True{
//for event in py.event.get(){  //User did something
//if event.type == py.QUIT{  //If user clicked close
//done = True  //Flag that we are done so we exit this loop
//elif event.type == py.MOUSEBUTTONDOWN{
////User clicks the mouse. Get the position
//pos = py.mouse.get_pos()
////Change the x/y screen coordinates to grid coordinates
//col = pos[0] // (WIDTH + MARGIN)
//row = pos[1] // (HEIGHT + MARGIN)
////Set that location to one
////grid[row][column] = "1"
//
//click_grid = str((row, col))
//if input_graph == "s"{
//click_g = str(round(seq_searcher.vertex_set[row][col].cost_list[seq_searcher.i], 5))
//click_h = str(round(seq_searcher.vertex_set[row][col].h_list[seq_searcher.i], 5))
//click_f = str(round(seq_searcher.vertex_set[row][col].f_list[seq_searcher.i], 5))
//else{
//click_g = str(round(searcher.vertex_set[row][col].cost, 5))
//click_h = str(round(searcher.vertex_set[row][col].h, 5))
//click_f = str(round(searcher.vertex_set[row][col].f, 5))
//
////Set the screen background
//screen.fill(BLACK)
//
////Draw the grid
//for row in range(TOTAL_ROWS){
//for col in range(TOTAL_COLS){
//color = WHITE
//if grid[row][col] == "a"{
//color = BLUE
//if grid[row][col] == "b"{
//color = GREEN
//if grid[row][col] == "2"{
//color = ORANGE
//if grid[row][col] == "0"{
//color = BLACK
//if grid[row][col] == "r"{
//color = RED
//if len(grid[row][col]) > 1{
//char = grid[row][col]
//if char[0] == "1"{
//color = DARK_WHITE
//if char[0] == "2"{
//color = DARK_ORANGE
//if char[0] == "a"{
//color = DARK_BLUE
//if char[0] == "b"{
//color = DARK_GREEN
//py.draw.rect(screen, color, [(MARGIN + WIDTH) * col + MARGIN, (MARGIN + HEIGHT) * row + MARGIN, WIDTH, HEIGHT])
//
//
//py.draw.rect(screen, (250,250,210), [980, 50, 200, 300])
//screen.blit(myfont.render("Coordinate", True, (BLACK)), (1000, 70))
//screen.blit(myfont.render(click_grid, True, (BLACK)), (1000, 120))
//screen.blit(myfont.render("g{ " +click_g, True, (BLACK)), (1000, 170))
//screen.blit(myfont.render("h{ " +click_h, True, (BLACK)), (1000, 220))
//screen.blit(myfont.render("f{ " +click_f, True, (BLACK)), (1000, 270))
//
//
//py.draw.rect(screen, (250,250,210), [980, 400, 200, 300])
//
//
//screen.blit(myfont.render(graph_type, True, (BLACK)), (1000, 420))
//screen.blit(myfont.render("g{ " + str(g_result), True, (BLACK)), (1000, 470))
//screen.blit(myfont.render("h{ "+ str(h_result), True, (BLACK)), (1000, 520))
//screen.blit(myfont.render("f{ "+ str(f_result), True, (BLACK)), (1000, 570))
//screen.blit(myfont.render(time_result, True, (BLACK)), (1000, 620))
//screen.blit(myfont.render(nodes +" nodes", True, (BLACK)), (1000, 670))
////Limit to 60 frames per second
////if path == nil{
////    pq, path = searcher.dijkstra_step(pathStart, pathGoal, pq)
//for i in xrange(STEP_SIZE){
//if path == nil{
//if(input_graph == "s"){
//grid = seq_searcher.grid
//pq, path = seq_searcher.sequential_a_star_step(pathStart, pathGoal, pq)
//g_result = round(seq_searcher.vertex_set[pathGoal[0]][pathGoal[1]].cost_list[seq_searcher.i], 5)
//h_result = round(seq_searcher.vertex_set[pathGoal[0]][pathGoal[1]].h_list[seq_searcher.i], 5)
//f_result = round(seq_searcher.vertex_set[pathGoal[0]][pathGoal[1]].f_list[seq_searcher.i], 5)
//nodes = str(seq_searcher.nodes_expanded)
//print(path)
//else{
//pq, path = searcher.a_star_step(pathStart, pathGoal, pq, input_weight, heursitic_input)
//g_result = round(searcher.vertex_set[pathGoal[0]][pathGoal[1]].cost, 5)
//h_result = round(searcher.vertex_set[pathGoal[0]][pathGoal[1]].h, 5)
//f_result = round(searcher.vertex_set[pathGoal[0]][pathGoal[1]].f, 5)
//nodes = str(searcher.nodes_expanded)
//time_result = "%s secs" % round((time.time() - start_time), 5)
////print time_result
//if path != nil{
//break
//
////Go ahead and update the screen with what we"ve drawn.
//py.display.flip()
//
////Be IDLE friendly. If you forget this line, the program will "hang"
////on exit.
//py.quit()

