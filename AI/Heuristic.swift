//
//  Heuristic.swift
//  AI
//
//  Created by Chikao Maeda on 5/19/18.
//  Copyright © 2018 Chikao Maeda. All rights reserved.
//

import Foundation
import Darwin

let MAX_COST = Float(1048576.0)
let NUM_H = 4

func cost_norm(_ choice: Character)->(Double){
    switch(choice){
        case "0": return 1048576.0
        case "1": return 0.5
        case "2": return 1.0
        case "a": return 0.125
        case "b": return 0.25
        case "r": return 0.0
        default:
            break
    }
    return 0.0
}

func cost_diag(_ choice: Character)->(Double){
    switch(choice){
        case "0": return 1048576.0
        case "1": return 0.70710678118
        case "2": return 1.41421356237
        case "a": return 0.17677669529
        case "b": return 0.35355339059
        case "r": return 0.0
    default:
        break
    }
    return 0.0
}

class Vertex{
    var row: Int //row of the grid
    var col: Int //column of the grid
    var type: Character //name of the vertex (0,1,2,a,b)
    var parent: Vertex? //The parent vertex
    var parent_list: [Vertex]? //List of parents each vertex has
    var cost: Float //g(n)
    var cost_list: [Double]?
    var closed: Bool
    var closed_list: [Vertex]? //All the verteces that have been accessed
    var h: Float //h(n)
    var f: Float // f(n) = g(n) + h(n)
    var f_list: [Float]?

    init(pos: [Int], vertex_type: Character){
        self.row = pos[0]
        self.col = pos[1]
        self.type = vertex_type //name of the vertex (0,1,2,a,b)
        self.parent = nil
        self.parent_list = nil
        self.cost = MAX_COST //initial value infinity
        self.cost_list = nil
        self.closed = false
        self.closed_list = nil
        self.h = 0
        self.f = self.cost + self.h
        self.f_list = nil
    }
  
//    func repr(){
//        if(self.closed){
//            return String((self.row, self.col)) + "1"
//        }
//        else{
//            return String((self.row, self.col)) + "0"
//        }
//        return String((self.row, self.col)) + "0"
//        //str(self.type) + str((self.row, self.col))
//    }
    
}


    func d1(node: Vertex, neighbor: Vertex) ->(Double){
        return cost_norm(node.type) + cost_norm(neighbor.type)
    }

    func d2(node: Vertex, neighbor: Vertex) ->(Double){
        return cost_diag(node.type) + cost_diag(neighbor.type)
    }
    func get_cost(n1: Vertex, n2: Vertex) -> (Float){
        if(abs(n1.row - n2.row) == 1 && abs(n1.col - n2.col) == 1){
            return Float(d2(node: n1, neighbor: n2))
        }else{
            return Float(d1(node: n1, neighbor: n2))
        }
    }

func consistant_heuristic(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float) -> (Float){
    let h_s = Float(pow(sqrt(Double(node.row - goal.row)), 2) + pow(Double(node.col - goal.col), 2))
    let h_ss = Float(pow(sqrt(Double(neighbor.row - goal.row)),2) + pow(Double(node.col - goal.col), 2))
    if (h_s <= Float(neighbor.cost) + h_ss){
        return weight*h_s
    }else{
        return weight*(Float(neighbor.cost) + h_ss)
    }
}


func manhattan_distance(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float)->(Float){
    let h_row = abs(node.row - goal.row)
    let h_col = abs(node.col - goal.col)
    return weight * Float((d1(node: node, neighbor: neighbor) * Double(h_row + h_col)))
}
//D * (dx + dy) + (D2 - 2 * D) * min(dx, dy)
func diagnol_distance(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float)->(Float){
    let h_row = abs(node.row - goal.row)
    let h_col = abs(node.col - goal.col)
    let D1 = Float(d1(node: node, neighbor: neighbor) * Double(h_row + h_col))
    let D2 = Float(d2(node: node, neighbor: neighbor) - 2 * d1(node: node, neighbor: neighbor))*Float(min(h_row, h_col))
    return weight*(D1 + D2)
}

func euclidean_distance(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float)->(Float){
    let h_row = abs(node.row - goal.row)
    let h_col = abs(node.col - goal.col)
    return weight * Float(d1(node: node, neighbor: neighbor) * sqrt(Double(h_row * h_row + h_col * h_col)))
}

//func given_heuristic(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float)->(Float){
//    let h_row = abs(node.row - goal.row)
//    let h_col = abs(node.col - goal.col)
//    return weight*(sqrt(2)* Double(min(h_row, h_col)) + max(h_row, h_col) - min(h_row, h_col))
//}


//enum HEURISTIC_MAP(choice: Int){
//    switch(choice){
//        case 0: consistant_heuristic
//        case 1: diagnol_distance
//        case 2: euclidean_distance
//        case 3: given_heuristic
//        case 4: manhattan_distance
//    }
//}

func heuristic_cost(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float, choice: Int)->(Float){
    switch(choice){
    case 0: return consistant_heuristic(node: node, neighbor: neighbor, goal: goal, weight: weight)
        case 1: return diagnol_distance(node: node, neighbor: neighbor, goal: goal, weight: weight)
        case 2: return euclidean_distance(node: node, neighbor: neighbor, goal: goal, weight: weight)
//        case 3: return given_heuristic(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float)
        case 3: return manhattan_distance(node: node, neighbor: neighbor, goal: goal, weight: weight)
        default:
            break
    }
}


class GraphSearch{
    var grid: [[String]]
    var vertex_set: [[Vertex]]
    var nodes_expanded: Int
    
    init(grid: [[String]]){
        self.grid = grid
        self.vertex_set = self.make_vertex_set()
        self.nodes_expanded = 0
    }

    
    //[Key: Value]
    func make_vertex_set()->([[Vertex]]){
        var vertex_set = [[Vertex]]()
        for i in self.grid{
            for j in self.grid[i]{
                vertex_set[i][j].append(Vertex(i, j), self.grid[i][j])
            }
        }
        return vertex_set
    }


    func retrieve_path(start: Vertex?, goal: Vertex?)->([Vertex?]?){
        var cur_node = goal
        var path = [goal]
        while(cur_node !== start){
            path.append(cur_node?.parent)
            cur_node = cur_node?.parent
            self.grid[(cur_node?.row)!][(cur_node?.col)!] = "r"
        }
        path.reverse()
        return path
    }


    func get_neighbors(node: Vertex)->([Vertex]){
        // Find 8 neighboring positions
        let x = node.row
        let y = node.col

        let top_left_pos = (x - 1, y + 1)
        let top_pos = (x, y + 1)
        let top_right_pos = (x + 1, y + 1)
        let right_pos = (x + 1, y)
        let bottom_right_pos = (x + 1, y - 1)
        let  bottom_pos = (x, y - 1)
        let bottom_left_pos = (x - 1, y - 1)
        let left_pos = (x - 1, y)

        var possible_neighbors = [top_left_pos, top_pos, top_right_pos, right_pos, bottom_right_pos, bottom_pos, bottom_left_pos, left_pos]

        // Filter out invalid neighbors (out of bounds or blocked cell)
        
        var counting = 0
        for position in possible_neighbors{
            if(!(position.0 >= 0 && position.0 < self.grid[0].count && position.0 >= 0 && position.1 < self.grid[0].count)){
                possible_neighbors.remove(at: counting)
            }
            counting += 1
        }
        
//
//        possible_neighbors = [position for position in possible_neighbors if position[0] >= 0 and position[0] < len(self.grid) and position[1] >= 0 and position[1] < len(self.grid[0])]
        var valid_neighbors = [Vertex]()

        for neighbor in possible_neighbors{
            let vertex = self.vertex_set[neighbor.0][neighbor.1]
            if(vertex.type != "0"){
                valid_neighbors.append(vertex)
            }
        }

        return valid_neighbors
    }
    func h_expand(node: Vertex, fringe: [Float: Vertex], goal: Vertex, weight: Float, heuristic_function: Int){
        var fringe = fringe
        if(node.closed == true){
            return
        }
        node.closed = true
        self.nodes_expanded += 1
        for neighbor in self.get_neighbors(node: node){
            let new_cost = get_cost(n1: node,n2: neighbor) + node.cost
            let h_s = heuristic_cost(node: node, neighbor: neighbor, goal: goal, weight: weight, choice: heuristic_function)
            if(!neighbor.closed){
                if (fringe[neighbor.cost] != nil){
                    fringe.removeValue(forKey: neighbor.cost)
                }
                if(new_cost < neighbor.cost){
                    neighbor.cost = new_cost
                    neighbor.h = h_s
                    neighbor.f = neighbor.cost + neighbor.h
                    neighbor.parent = node
                }
                fringe[neighbor.f] = neighbor
            }
            
        }
        
        if(self.grid[node.row][node.col] != "r"){
            self.grid[node.row][node.col] += "S"
        }
        fringe.sorted(by: {$0.0 < $1.0})
//        hq.heapify(fringe)
    }
//    func a_star_step(node: Vertex, neighbor: Vertex, goal: Vertex, weight: Float, heuristic_function: Int) -> (Vertex,Vertex){
    func a_star_step(start: (Int, Int), goal: (Int, Int), pq: [(Float, Vertex)], weight:Float , heuristic_function: Int) -> ((Float, Vertex)){
        var pq = pq
//        var startArray = start.split(separator: " ")
//        var goalArray = goal.split(separator: " ")
//        var start_vertex = self.vertex_set[startArray[0]][Int(startArray[1])]
//        var goal_vertex = self.vertex_set[goalArray[0]][goalArray[1]]
        var start_vertex = self.vertex_set[start.0][start.1]
        var goal_vertex = self.vertex_set[goal.0][goal.1]
        var path: (Float, Vertex)? = nil

        if(pq == nil){
            start_vertex.cost = 0
            start_vertex.f = start_vertex.cost
            pq = [(start_vertex.f, start_vertex)]
            pq.sorted(by: {$0.0 < $1.0})
        }

        if(pq.count == 0){
            print("no path found")
            return (0.0, nil)
        }

        var vertex = pq.removeFirst()
        if(vertex.1.row == goal.0 && vertex.1.col == goal.1){
            path = self.retrieve_path(start: start_vertex, goal: vertex.1)
        }
        //print path, vertex.cost

        return (nil, path)
        self.h_expand(vertex, pq, goal_vertex, weight, heuristic_function)

//        return (pq, nil)
        return pq
    }

}


///////////////////////////////////////////////
class A_Star_Seq :GraphSearch{
    var w1: Float
    var w2: Float
    var initialized: Bool
    var i: Int
    init(grid: [[String]], w1: Float, w2: Float){
        self.w1 = w1
        self.w2 = w2
        self.grid = grid
        vertex_set = self.make_vertex_set()
        for i in vertex_set.count{
            for j in vertex_set[i].count{
                //list for each heuristic
                for heuristic in NUM_H{
                    vertex_set[i][j].closed_list.append(false)
                    vertex_set[i][j].parent_list.apend(nil)
                    vertex_set[i][j].cost_list.append(MAX_COST)
                    vertex_set[i][j].f_list.append(MAX_COST)
                    vertex_set[i][j].h_list.append(MAX_COST)
                }
//                vertex_set[i][j].closed_list = [false for k in xrange(NUM_H)]
//                vertex_set[i][j].parent_list = [nil for k in xrange(NUM_H)]
//                vertex_set[i][j].cost_list = [MAX_COST for k in xrange(NUM_H)]
//                vertex_set[i][j].f_list = [MAX_COST for k in xrange(NUM_H)]
//                vertex_set[i][j].h_list = [MAX_COST for k in xrange(NUM_H)]
            }
        }
        self.vertex_set = vertex_set
        self.initialized = false
        self.nodes_expanded = 0
        self.i = 0
    }
    
    func sequential_a_star_step(start: (Int, Int), goal: (Int, Int), pqs: [[(Float, Vertex)]]){
        var pqs = pqs
        var start_vertex = self.vertex_set[start.0][start.1]
        var goal_vertex = self.vertex_set[goal.0][goal.1]
        if(self.initialized == false){
            self.vertex_set[start.0][start.1].cost_list = [0 for i in xrange(NUM_H)]
            pqs = [[(0, start_vertex)] for i in xrange(NUM_H)]
            self.initialized = true
        }
        
        var vertex_start = pqs[0].removeFirst()
        let cost0 = vertex_start.0
        let vertex0 = vertex_start.1
    
        var expanded = false
        for i in 1 ... NUM_H {
            var vertexTuple = pqs[i].removeFirst()
            let cost = vertexTuple.0
            let vertex = vertexTuple.1
            if(cost <= self.w2*cost0){
                if(goal_vertex.cost_list[i] < MAX_COST){
                    self.i = i
                    return nil, self.retrieve_path(start_vertex, goal_vertex, i)
                }
                else{
                    self.expand(vertex, pqs, goal_vertex, i)
                }
                
            }
            else{
                hq.append(pqs[i], (cost, vertex))
                if(goal_vertex.cost_list[0] < cost0){
                    if(goal_vertex.cost_list[0] < MAX_COST){
                        self.i = i
                        return nil, self.retrieve_path(start_vertex, goal_vertex, 0)
                    }
                }
                else{
                    expanded = true
                }
            }
        }
        
        self.expand(vertex0, pqs, goal_vertex, 0)
        if(expanded == false){
            hq.append(pqs[0], (cost0, vertex0))
        }
        
        return pqs, nil
    }
    
}


