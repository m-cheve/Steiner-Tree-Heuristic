module IntSet = Set.Make(struct type t = int let compare = (-) end)

(* Create Graphic *)
let draw_edge ((x1,y1),(x2,y2)) =
    let _ = Graphics.moveto x1 y1 in
    Graphics.lineto x2 y2

let draw_pb pts =
    let c = Graphics.foreground in
    let _ = Graphics.set_color Graphics.black in
    let _ = List.iter (fun (x,y) -> Graphics.fill_circle x y 5) pts in
    Graphics.set_color c

let draw_sol sol =
    let c = Graphics.foreground in
    let _ = Graphics.set_color Graphics.red in
    let _ = Graphics.set_line_width 3 in
    let _ = List.iter draw_edge sol in
    let _ = Graphics.set_line_width 1 in
    Graphics.set_color c

let draw (sx,sy) pts sol =
    let args = Printf.sprintf " %dx%d" sx sy in
    let _ = Graphics.open_graph args in
    let _ = draw_pb pts in
    let _ = draw_sol sol in
    let _ = Graphics.wait_next_event [Graphics.Key_pressed] in
    Graphics.close_graph ()


let draw_steiner (sx,sy) pts sol =
    let ps0 = List.map (fun (x,y) -> (float_of_int x, float_of_int y)) pts in
    let ps  = List.fold_left (fun acc (c1,c2) -> c1::c2::acc) ps0 sol in
    let xm  = List.fold_left (fun acc (x,_) -> min acc x) infinity ps in
    let xM  = List.fold_left (fun acc (x,_) -> max acc x) neg_infinity ps in
    let ym  = List.fold_left (fun acc (_,y) -> min acc y) infinity ps in
    let yM  = List.fold_left (fun acc (_,y) -> max acc y) neg_infinity ps in
    let margin  = 10 in
    let _ = if sx <= 2 * margin
            then failwith "[draw_steiner] width must be more than 20px."
            else ()
    in
    let _ = if sy <= 2 * margin
            then failwith "[draw_steiner] height must be more than 20px."
            else ()
    in
    let shift_x = float_of_int margin -. xm in
    let shift_y = float_of_int margin -. ym in
    let eps     = 1e-6 in
    let zoom_x  = max eps (float_of_int (sx - 2 * margin) /. (max eps (xM -. xm))) in
    let zoom_y  = max eps (float_of_int (sy - 2 * margin) /. (max eps (yM -. ym))) in
    let adjust (x,y) =
        ( int_of_float (shift_x +. zoom_x *. x)
        , int_of_float (shift_y +. zoom_y *. y)
        )
    in
    let pts' = List.map adjust ps0 in
    let sol' = List.map (fun (c1,c2) -> (adjust c1, adjust c2)) sol in
    draw (sx,sy) pts' sol'


(* Read Input *)
let dump_coord (x,y) =
  Printf.printf "(%d,%d) " x y

let dump l =
  let _ = Printf.printf "{ " in
  let _ = List.iter dump_coord l in
  Printf.printf "}\n%!"

let read_coords =
  let rec aux acc n =
      if n = 0
      then List.rev acc
      else let c = Scanf.scanf "%d %d\n" (fun x y -> (x,y))
            in aux (c::acc) (n-1)
  in
  fun n -> aux [] n

(* Program *)

(* let _ = dump (read_coords 0);;*)

let _ = draw_steiner (500,500) (read_coords 9) (((2.,1.),(2.,2.))::((0.,1.),(2.,0.))::((1.,1.),(0.,2.))::((1.,1.),(2.,2.))::((1.,1.),(1.,2.))::((0.,0.),(0.,1.))::((0.,0.),(1.,1.))::((1.,1.),(1.,0.))::[]);;