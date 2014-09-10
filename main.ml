
(*
copyright (c) 2013-2014, guillaume bury
all rights reserved.

redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.  redistributions in binary
form must reproduce the above copyright notice, this list of conditions and the
following disclaimer in the documentation and/or other materials provided with
the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

open Q
open Format
module S = Simplex.Make(struct type t = int let compare = Pervasives.compare end)
;;

let max_depth = 5
let max_rand = 100
let bound_range = 30

let svar x = sprintf "v%d" x

let print_var fmt x = fprintf fmt "%s" (svar x)

let print_short fmt = function
    | S.Solution _ -> fprintf fmt "SAT"
    | S.Unsatisfiable _ -> fprintf fmt "UNSAT"

let print_res f fmt = function
    | S.Solution l ->
            fprintf fmt "Sol:@\n%a@." (fun fmt -> List.iter (fun (x, v) -> fprintf fmt "%a : %s@\n" print_var x (to_string v))) l
    | S.Unsatisfiable c -> fprintf fmt "UNSAT:@\n%a@." f c

let print_unsat fmt (x, l) =
    fprintf fmt "%a =@ @[<hov 2>%a@]" print_var x (fun fmt l ->
        if l = [] then fprintf fmt "()" else List.iter (fun (c, x) -> fprintf fmt "%s * %a +@ " (to_string c) print_var x) l) l

let print_abs fmt l =
    let aux (x, (e, k)) =
        fprintf fmt "v%d == %a%s@." x
        (fun fmt -> List.iter (fun (c, x) -> fprintf fmt "%s * v%d + " (to_string c) x)) e
        (to_string k)
    in
    List.iter aux l

let rec print_branch n fmt b =
    if n > max_depth then
        fprintf fmt "..."
    else match !b with
    | None -> raise Exit
    | Some (S.Branch (x, v, c1, c2)) ->
            fprintf fmt "@[<hov 6>%a <= %s :@\n%a@]@\n@[<hov 6>%a >= %s :@\n%a@]"
            print_var x (Z.to_string v) (print_branch (Pervasives.(+) n 1)) c1
            print_var x (Z.to_string (Z.succ v)) (print_branch (Pervasives.(+) n 1)) c2
    | Some (S.Explanation c) ->
            fprintf fmt "Unsat:@ %a" print_unsat c

let print_ksol = print_res print_unsat
let print_nsol = print_res (print_branch 0)

let main () =
    let s = S.empty in
    let s = S.add_bounds s ~strict_lower:true ~strict_upper:true (1, of_int 1, of_int 2) in
    (*
    let s = S.add_eq s (10, [of_int 1, 1; of_int 1, 2]) in
    let s = S.add_bounds s (2, of_int 1, inf) in
    let s = S.add_bounds s (10, minus_inf, of_int 2) in
    *)
    if 0 = 0 then begin
        let res = S.ksolve ~debug:(S.print_debug print_var) s in
        fprintf std_formatter "%a@." print_ksol res
    end else begin
        let res = S.nsolve s (fun _ -> true) in
        fprintf std_formatter "%a@\n%a@."
            (S.print_debug print_var) s
            print_nsol res
    end;
    ()


let () =
    main ()
