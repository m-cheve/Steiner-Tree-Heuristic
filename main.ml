open Display
open Read

module G = Graph.Make(Graph.MyNode);;

Random.self_init ();;

(* The Number of iteration used to create the steiner graph *)
let number_of_iterations = 100000;;

let coords_list = read ();;

let steiner () =
    let graph = G.create_graph coords_list in
    let result = G.steiner graph number_of_iterations in
    G.to_list result

let result = steiner ();;
let _ = draw_steiner (700,700) coords_list result;;
()