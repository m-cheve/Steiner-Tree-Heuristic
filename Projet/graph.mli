module type MyNode =
  sig
    type t

    val compare : t -> t -> int

    val weight : t -> t -> float
  end

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

module Make(X:MyNode) : Graph with type node = X.t