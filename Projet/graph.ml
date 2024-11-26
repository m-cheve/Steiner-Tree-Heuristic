(* Node OrderedType *)
module type MyNode =
  sig
    type t

    val compare : t -> t -> int

    val weight : t -> t -> float
  end

module MyNode =
  struct
    (** x: the x coordinate
        y: the y coordinate
        pr: the node is a relay point [true] or not [false] *)
    type t = (float * float * bool)

    let compare (x1, y1, pr1) (x2, y2, pr2) =
      if x1 < x2 then -1
      else if x1 > x2 then 1
      else if y1 < y2 then -1
      else if y1 > y2 then 1
      else if not pr1 && pr2 then -1
      else if pr1 = pr2 then 0
      else
        1

    let weight (x1, y1, pr1) (x2, y2, pr2) =
      Float.sqrt ((x2 -. x1) *. (x2 -. x1) +. (y2 -. y1) *. (y2 -. y1))

  end

(* Graph module *)
module type Graph =
    sig
    type node
    module NodeSet : Set.S with type elt = node
    type graph

    val empty : graph
    val is_empty : graph -> bool
    val add_node : node -> graph -> graph
    val add_edge : node -> node -> graph -> graph

    val succs : node -> graph -> NodeSet.t

    val mem_node : node -> graph -> bool
    val mem_edge : node -> node -> graph -> bool

    val remove_node : node -> graph -> graph
    val remove_edge : node -> node -> graph -> graph

    val fold_node : (node -> 'value -> 'value) -> graph -> 'value -> 'value
    val fold_edge : (node -> node -> 'value -> 'value) -> graph -> 'value -> 'value
end

module Make(O:MyNode) =
  struct
    module NodeSet = Set.Make(O)
    module NodeMap = Map.Make(O)
    type node = NodeSet.elt
                 (* the weight of the graph * the graph *)
    type graph = (float * NodeSet.t NodeMap.t)

    let empty = (0., NodeMap.empty)

    let is_empty (p,g) =
      p = 0. && NodeMap.is_empty g

    let add_node n (p,g) =
      try let _ = NodeMap.find n g in
        (p,g)
      with Not_found ->
        (p,NodeMap.add n NodeSet.empty g)

    let add_edge src dst (p,g) =
      let g1 = add_node src (p,g) in
      let p2, g2 = add_node dst g1 in
      let old_src_succs = NodeMap.find src g2 in
      let new_src_succs = NodeSet.add dst old_src_succs in
      (p +. O.weight src dst, NodeMap.add src new_src_succs g2)

    let succs n (p,g) =
      try let n_succs = NodeMap.find n g in
        n_succs
      with Not_found ->
        NodeSet.empty

    let mem_node n (p,g) =
      try let _ = NodeMap.find n g in
        true
      with Not_found ->
        false

    let mem_edge src dst g =
      let src_succs = succs src g in
      NodeSet.mem dst src_succs

    let remove_node n (p,g) =
      try let suc = NodeMap.find n g in
        let removed_n = NodeMap.remove n g in
        (
          p -.
          NodeSet.fold
          (fun dst -> fun dist ->
            dist +. O.weight n dst)
          suc
          0.
        ,
          NodeMap.fold
          (fun src -> fun dst -> fun acc ->
            NodeMap.add src (NodeSet.remove n dst) acc)
          removed_n
          NodeMap.empty
        )
      with Not_found ->
        (p, g)

    let remove_edge src dst (p,g) =
      try let _ = NodeMap.find src g in
        let src_succs = succs src (p,g) in
        let new_src_succs = NodeSet.remove dst src_succs in
        if NodeSet.mem dst src_succs then
          (p -. O.weight src dst, NodeMap.add src new_src_succs g)
        else
          (p, NodeMap.add src new_src_succs g)
      with Not_found ->
        (p,g)

    let fold_node f (p,g) v0 =
      NodeMap.fold
      (fun key _ acc -> f key acc)
      g
      v0

    let fold_edge f (p,g) v0 =
      NodeMap.fold
      (fun key data acc ->
        NodeSet.fold
        (fun elt acc2 ->
          f key elt acc2
        )
        data
        acc
      )
      g
      v0
  end