open AbstractSyntax;;
open PrintStuff;;

module VarSet = Set.Make(String);;

let rec check_prog (Stmtlist p) = check_stmt_list p VarSet.empty 

and
check_stmt_list p v0 = match p with
  Empty -> false
| Stmt (c, l) -> match c with
	| Declare v -> (check_stmt_list l (VarSet.add v v0))
	| Call (i, e) -> (check_iden i v0) || (check_exp e v0) || (check_stmt_list l v0)
	| Malloc v -> not (VarSet.mem v v0) || (check_stmt_list l v0)
	| Assign (i, e) -> (check_iden i v0) || (check_exp e v0) || (check_stmt_list l v0)
	| While (b, l) -> (check_bool b v0) || (check_stmt_list l v0) 
	| If (b, l1, l2) -> (check_bool b v0) || (check_stmt_list l1 v0) || (check_stmt_list l2 v0)
	| Atom l -> (check_stmt_list l v0)
	| Parallel (l1, l2) -> (check_stmt_list l1 v0) || (check_stmt_list l2 v0)
	| Skip -> (check_stmt_list l v0)
    | Print e -> (check_exp e v0) || (check_stmt_list l v0)

and
check_exp e v0 = match e with 
  Num n -> false
| Arith (e1, aO, e2) -> (check_exp e1 v0) || (check_exp e2 v0)
| Iden i -> check_iden i v0
| Null -> false
| Proc (v, l) -> check_stmt_list l (VarSet.add v v0)

and
check_iden i v0 = match i with
  Var v -> if not (VarSet.mem v v0) then print_string ("Variable " ^ v ^ " not in the scope.\n") else (); not (VarSet.mem v v0)
| Deref (v,i) -> if not (VarSet.mem v v0) then print_string ("Variable " ^ v ^ " not in the scope.\n") else (); not (VarSet.mem v v0) 

and
check_bool b v0 = match b with
  Bool b0 -> false
| Expression (e1, bO, e2) -> (check_exp e1 v0) || (check_exp e2 v0)

let static_check = check_prog