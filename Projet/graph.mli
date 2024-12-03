module type MyNode =
  sig
    type t

    (**
      @requires, ()
      @ensures [compare n1 n2]
              returns [-1] if [n1 < n2]
                      [0] if [n1 == n2]
                      [1] if [n1 > n2]
      @raises, ()
    *)
    val compare : t -> t -> int

    val x_value : t -> float

    val y_value : t -> float

    val is_pr : t -> bool

    val create_node : float -> float -> bool -> t

    (**
      @requires, ()
      @ensures [weight n1 n2] returns the weight of the edge linking [n1] and [n2]
      @raises, ()
    *)
    val weight : t -> t -> float
  end

module type Graph =
    sig
    type node
    module NodeSet : Set.S with type elt = node
    type graph

    val empty : graph
    (** L'ensemble vide *)

    (**
      @requires, ()
      @ensures [is_empty g] test if the graph [g] is empty
      @raises, ()
    *)
    val is_empty : graph -> bool

    (**
      @requires, ()
      @ensures [add_node n g] adds the node [n] to the graph [g]
      @raises, ()
    *)
    val add_node : node -> graph -> graph

    (**
      @requires, ()
      @ensures [add_edge src dst g] adds an edge between [src] and [dst]

            Rq:
              1- if [src] or [dst] doesn't exist, they are added to the graph [g]
              2- the weight of the edge is added to the total weight of the graph [g]
      @raises, ()
    *)
    val add_edge : node -> node -> graph -> graph


    (**
      @requires, ()
      @ensures [succs n g] returns the successors of [n] in [g]

            Rq:
              1- If [n] does not have successors, [NodeSet.empty] is returned
      @raises, ()
    *)
    val succs : node -> graph -> NodeSet.t

    (**
      @requires, ()
      @ensures [mem_node n g] returns [true] if [n] is in [g]
                and [false] otherwise
      @raises, ()
    *)
    val mem_node : node -> graph -> bool

    (**
      @requires, ()
      @ensures [mem_edge src dst g]
                returns [true] if the edge between [src] and [dst] is in [g]
                and [false] otherwise
      @raises, ()
    *)
    val mem_edge : node -> node -> graph -> bool

    (**
      @requires, ()
      @ensures [remove_node n g]
                removes [n] from [g] and returns the result

                Rq:
                  1- If [n] is not in [g] then [g] is returned
      @raises, ()
    *)
    val remove_node : node -> graph -> graph

    (**
      @requires, ()
      @ensures [remove_edge src dst g]
                removes the edge between [src] and [dst] from [g] and returns the result

                Rq:
                  1- If the edge is not in [g] then [g] is returned
      @raises, ()
    *)
    val remove_edge : node -> node -> graph -> graph

    (**
      @requires, ()
      @ensures [fold_node f g v0]
                Applies [f] to every node of [g] with [v0] as the accumulator
      @raises, ()
    *)
    val fold_node : (node -> 'value -> 'value) -> graph -> 'value -> 'value

    (**
      @requires, ()
      @ensures [fold_edge f g v0]
                Applies [f] to every edge of [g] with [v0] as the accumulator
      @raises, ()
    *)
    val fold_edge : (node -> node -> 'value -> 'value) -> graph -> 'value -> 'value

    (**
      @requires, ()
      @ensures [to_list g] convert [g] to a list of edges
      @raises, ()
    *)
    val to_list : graph -> ((float * float) * (float * float)) list

    (**
      @requires the list to contain positive values
      @ensures [create_graph l] add every node contain in [l]
                where an element of [l] has the form [(x, y)]
                it also create an edge between the element [(x, y)]
                and its successor in the list in order to create a connex graph
      @raises, ()
    *)
    val create_graph : (float * float) list -> graph
end

module Make(X:MyNode) : Graph with type node = X.t