(* Node OrderedType *)
module type MyNodeType =
  sig
    type t

    val compare : t -> t -> int

    val x_value : t -> float
    val y_value : t -> float
    val is_pr : t -> bool

    val create_node : float -> float -> bool -> t

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

    let x_value (x, y, pr) = x
    let y_value (x, y, pr) = y
    let is_pr (x, y, pr) = pr

    let create_node x y pr = (x, y, pr)

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

    val to_list : graph -> ((float * float) * (float * float)) list

    val create_graph : (float * float) list -> graph
end

module Make(O:MyNodeType) =
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

    let to_list g =
      fold_edge (
        fun src dst acc ->
          ((O.x_value src, O.y_value src),(O.x_value dst, O.y_value dst))::acc
      )
      g
      []

    let create_graph list =
      (** [set] is used to store elements that are already in the graph *)
      let rec create_graph_aux l set = match l with
        |[] -> empty
        |[(x, y)] ->
          add_node (O.create_node x y false) empty
        |(x1, y1)::(x2, y2)::t ->
          (** As we want to connect every node without creating a cycle,
              We check if [dst] is already in the graph *)
          let src = O.create_node x1 y1 false in
          let dst = O.create_node x2 y2 false in
          if NodeSet.mem dst set then (* if it is, we skip this node *)
            create_graph_aux ((x1,y1)::t) set
          else
            (* if it isn't we add it to the graph and try to connect it with other nodes *)
            let g = create_graph_aux ((x2,y2)::t) (NodeSet.add dst set) in
            add_edge src dst g in
      match list with
      |[] -> empty
      |(x, y)::t ->
        (** Adding the first element to the set as [create_graph_aux] doesn't do it *)
        let new_node = O.create_node x y false in
        create_graph_aux list (NodeSet.add new_node NodeSet.empty)

    (**
      @requires, ()
      @ensures [create_barycentre_pr n1 n2 n3] returns a relay point node that is at the
                barycentre of [n1] [n2] and [n3]
      @raises, ()
    *)
    let create_barycentre_pr n1 n2 n3 =
      let x = ((O.x_value n1) +. (O.x_value n2) +. (O.x_value n3)) /. 3. in
      let y = ((O.y_value n1) +. (O.y_value n2) +. (O.y_value n3)) /. 3. in
      O.create_node x y true

    (**
      @requires [src] is linked to [dst1] and [dst2]
                but [dst1] is not linked to [dst2]
      @ensures [place_pr g src dst1 dst2] remove edges between [src] and [dst1]
                but also between [src] and [dst2].
                Then the program creates a relay point and link it to [src], [dst1] and [dst2]
      @raises, ()
    *)
    let place_pr g src dst1 dst2 =
      (* As the graph is oriented, we remove every possible edge between src, dst1 and dst2*)
      let g1 = remove_edge src dst1 g in
      let g2 = remove_edge dst1 src g1 in
      let g3 = remove_edge src dst2 g2 in
      let g4 = remove_edge dst2 src g3 in
      let g5 = remove_edge dst1 dst2 g4 in
      let g6 = remove_edge dst2 dst1 g5 in

      (* Create the barycenter *)
      let new_pr = create_barycentre_pr src dst1 dst2 in

      (* Link the barycentre to src, dst1 and dst2 *)
      let g7 = add_edge new_pr src g6 in
      let g8 = add_edge new_pr dst1 g7 in
      add_edge new_pr dst2 g8

    (**
      @requires [g] has at least one node
      @ensures [pick_node graph] returns a random node from [g]
      @raises, ()
    *)
    let pick_node (p,g) =
      let _, result, _ =
        fold_node (
          fun n (is_chosen, node, number_of_nodes) ->
            if is_chosen then
              (true, node, number_of_nodes)
            else
              let result = Random.int number_of_nodes in
              if result = 0 then
                (true, n, number_of_nodes - 1)
              else
                (false, node, number_of_nodes - 1)
        )
        (p,g)
        (false, fst (NodeMap.choose g), NodeMap.cardinal g) in
      result

    (**
      @requires [n] has at least one successor
      @ensures [pick_succs n graph] returns a random successor of [n]
      @raises, ()
    *)
    let pick_succs n (p,g) =
      let succs = succs n (p,g) in
      let _, result, _ =
        NodeSet.fold (
          fun n (is_chosen, node, number_of_nodes) ->
            if is_chosen then
              (true, node, number_of_nodes)
            else
              let result = Random.int number_of_nodes in
              if result = 0 then
                (true, n, number_of_nodes - 1)
              else
                (false, node, number_of_nodes - 1)
        )
        succs
        (false, NodeSet.choose succs, NodeSet.cardinal succs) in
      result

    (**
      @requires [g] has at least 3 nodes
      @ensures [find_parent graph] returns a parent of [n1] or [n2]
                that is not [n1] or [n2]
      @raises, ()
    *)
    let find_parent (p,g) n1 n2 =
      let _, result =
        fold_node (
          fun n' (is_chosen, node) ->
            if is_chosen then
              (true, node)
            else
              if n' = n1 || n' = n2 then
                (false, node)
              else
                let succs_n = succs n' (p,g) in
                if NodeSet.mem n1 succs_n || NodeSet.mem n2 succs_n then
                  (true, n')
                else
                  (false, node)
        )
        (p,g)
        (false, n1) in
      result

    (**
      @requires [g] has at least 3 nodes
      @ensures [find_triangle graph] returns 3 nodes that are linked together
      @raises, ()
    *)
    let find_triangle (p,g) =
      if NodeMap.cardinal g < 3 then
        failwith "Not enough nodes in the graph"
      else
      let n1 = pick_node (p,g) in
      let n2 = if NodeSet.cardinal (succs n1 (p,g)) = 0 then find_parent (p,g) n1 n1 else pick_succs n1 (p,g) in
      let n3 = if NodeSet.cardinal (succs n2 (p,g)) = 0 then find_parent (p,g) n1 n2 else pick_succs n2 (p,g) in
      (n1, n2, n3)

    (**
      @requires [g] has at least 3 nodes
      @ensures [action_create_pr graph] creates a relay point in the middle of a triangle
      @raises, ()
    *)
    let action_create_pr (p,g) =
      let n1, n2, n3 = find_triangle (p,g) in
      place_pr (p,g) n1 n2 n3

    (**
      @requires ()
      @ensures [get_pr_list graph] returns the list of relay points in [g]
      @raises, ()
    *)
    let get_pr_list (p,g) =
      fold_node (
        fun n acc ->
          if O.is_pr n then
            n::acc
          else
            acc
      )
      (p,g)
      []

    (**
      @requires [l] is not empty
      @ensures [pick_rancom_element_from_list l] returns a random element from [l]
      @raises, ()
    *)
    let pick_rancom_element_from_list l =
      if List.length l = 0 then
        failwith "Empty list"
      else
        List.nth l (Random.int (List.length l))

    (**
      @requires ()
      @ensures [find_parents (p,g) n] returns the set of parents of [n] in [g]
      @raises, ()
    *)
    let find_parents (p,g) n =
      fold_node (
        fun n' acc ->
          if NodeSet.mem n (succs n' (p,g)) then
            NodeSet.add n' acc
          else
            acc
      )
      (p,g)
      NodeSet.empty


    (**
      @requires [pr] is a relay point in [g]
      @ensures [move_pr g pr] moves the relay point [pr] to a random position
      @raises, ()
    *)
    let move_pr g pr =
      let parents = find_parents g pr in
      let succs_pr = succs pr g in

      let x1 = O.x_value pr +. if  Random.bool () then Random.float 1. else -1. *. Random.float 1. in
      let y1 = O.y_value pr +. if  Random.bool () then Random.float 1. else -1. *. Random.float 1. in

      let new_pr = O.create_node x1 y1 true in

      let g1 = NodeSet.fold (
        fun parent acc ->
          let g' = remove_edge parent pr acc in
          add_edge parent new_pr g'
      )
      parents
      g in

      NodeSet.fold (
        fun succ acc ->
          let g' = remove_edge pr succ acc in
          add_edge new_pr succ g'
      )
      succs_pr
      g1
  end