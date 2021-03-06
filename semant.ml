(* Democritus, adapted from MicroC by Stephen Edwards Columbia University *)
(* Semantic checking for compiler *)

open Ast

module StringMap = Map.Make(String)
module StringSet = Set.Make(String)

(* Semantic checking of a program. Returns void if successful,
throws an exception if something is wrong.

Check each global variable, then check each function *)

let check (globals, functions, structs) =

(* Raise an exception if the given list has a duplicate *)
  let report_duplicate exceptf list =
    let rec helper = function
	n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
      | _ :: t -> helper t
      | [] -> ()
    in helper (List.sort compare list)
  in

  (*Raise an exception if there is a recursive struct dependency*)
  
  let find_sdecl_from_sname struct_type_name =
    try List.find (fun s-> s.sname= struct_type_name) structs 
      with Not_found -> raise (Failure("Struct of name " ^ struct_type_name ^ "not found.")) 
  in
  let rec check_recursive_struct_helper sdecl seen_set =
    let check_if_repeat struct_type_name =
      let found = StringSet.mem struct_type_name seen_set in
      if found then raise (Failure ("recursive struct definition"))
      else check_recursive_struct_helper (find_sdecl_from_sname struct_type_name)  (StringSet.add struct_type_name seen_set)
    in
    let is_struct_field = function
      (StructType s, _) -> check_if_repeat s
     | _ -> () 
    in
    List.iter (is_struct_field) sdecl.sformals
  in
  let check_recursive_struct sdecl =
     check_recursive_struct_helper sdecl StringSet.empty    
  in
  let _ = List.map check_recursive_struct structs
  in
  (* Raise an exception if a given binding is to a void type *)
  let check_not_void exceptf = function
      (Void, n) -> raise (Failure (exceptf n))
    | _ -> ()
  in
  
  (* Raise an exception of the given rvalue type cannot be assigned to
     the given lvalue type *)
  let check_assign lvaluet rvaluet err =
	if (String.compare (string_of_typ lvaluet) (string_of_typ rvaluet)) == 0
	then lvaluet
	else raise err
     (*if lvaluet == rvaluet then lvaluet else raise err*)
  in

  let match_struct_to_accessor a b = 
    let  s1 = try List.find (fun s-> s.sname=a) structs 
      with Not_found -> raise (Failure("Struct of name " ^ a ^ "not found.")) in
    try fst( List.find (fun s-> snd(s)=b) s1.sformals) with
	Not_found -> raise (Failure("Struct " ^ a ^ " does not have field " ^ b))
  in

  let check_access lvaluet rvalues =
     match lvaluet with
       StructType s -> match_struct_to_accessor s rvalues
       | _ -> raise (Failure(string_of_typ lvaluet ^ " is not a struct"))
	
  in

  (**** Checking Global Variables ****)

  List.iter (check_not_void (fun n -> "illegal void global " ^ n)) globals;
   
  report_duplicate (fun n -> "duplicate global " ^ n) (List.map snd globals);

  (**** Checking Functions ****)

  if List.mem "append_strings" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function append_strings may not be defined")) else ();

  if List.mem "int_to_string" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function int_to_string may not be defined")) else ();

  if List.mem "print" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function print may not be defined")) else ();

  if List.mem "thread" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function thread may not be defined")) else ();

  if List.mem "exec_prog" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function exec_prog may not be defined")) else ();

  if List.mem "free" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function free may not be defined")) else ();

  if List.mem "malloc" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function malloc may not be defined")) else ();

  if List.mem "open" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function open may not be defined")) else ();

  if List.mem "close" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function close may not be defined")) else ();

  if List.mem "read" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function read may not be defined")) else ();

  if List.mem "write" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function write may not be defined")) else ();

  if List.mem "lseek" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function lseek may not be defined")) else ();

  if List.mem "sleep" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function sleep may not be defined")) else ();
 
 if List.mem "request_from_server" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function request_from_server may not be defined")) else ();

  if List.mem "memset" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function memset may not be defined")) else ();

  report_duplicate (fun n -> "duplicate function " ^ n)
    (List.map (fun fd -> fd.fname) functions);

  (* Function declaration for a named function *)
  let built_in_decls_funcs = [
      { typ = Void; fname = "print_int"; formals = [(Int, "x")];
      locals = []; body = [] };

      { typ = Void; fname = "printb"; formals = [(Bool, "x")];
      locals = []; body = [] }; 

      { typ = Void; fname = "print_float"; formals = [(Float, "x")];
      locals = []; body = [] }; 

      { typ = Void; fname = "thread"; formals = [(MyString, "func"); (MyString, "arg"); (Int, "nthreads")]; locals = []; body = [] };

      { typ = MyString; fname = "malloc"; formals = [(Int, "size")]; locals = []; body = [] };

     (* { typ = DerefAndSet; fname = "malloc"; formals = [(Int, "size")]; locals = []; body = [] }; *)

      { typ = Int; fname = "open"; formals = [(MyString, "name"); (Int, "flags"); (Int, "mode")]; locals = []; body = [] };

      { typ = Int; fname = "close"; formals = [(Int, "fd")]; locals = []; body = [] };

      { typ = Int; fname = "read"; formals = [(Int, "fd"); (MyString, "buf"); (Int, "count")]; locals = []; body = [] };

      { typ = Int; fname = "write"; formals =  [(Int, "fd"); (MyString, "buf"); (Int, "count")]; locals = []; body = [] };

      { typ = Int; fname = "lseek"; formals =  [(Int, "fd"); (Int, "offset"); (Int, "whence")]; locals = []; body = [] };

      { typ = Int; fname = "sleep"; formals =  [(Int, "seconds")]; locals = []; body = [] };
      
      { typ = Int; fname = "memset"; formals =  [(MyString, "s"); (Int, "val"); (Int, "size")]; locals = []; body = [] };

      { typ = MyString; fname = "request_from_server"; formals = [(MyString, "link")]; locals = []; body = [] } 
;

      { typ = Int; fname = "exec_prog"; formals = [(MyString, "arg1"); (MyString, "arg2"); (MyString, "arg3") ]; locals = []; body = [] };

      { typ = Void; fname = "free"; formals = [(MyString, "tofree")]; locals = []; body = [] }
;

      { typ = Void; fname = "append_strings"; formals = [(MyString, "str1"); (MyString, "str2")]; locals = []; body = [] };
 
     
      { typ = Void; fname = "int_to_string"; formals = [(Int, "n"); (MyString, "buf")]; locals = []; body = [] }
]

  in

 let built_in_decls_names = [ "print_int"; "printb"; "print_float"; "thread"; "malloc"; "open"; "close"; "read"; "write"; "lseek"; "sleep"; "memset"; "request_from_server"; "exec_prog"; "free"; "append_strings"; "int_to_string" ]

  in

  let built_in_decls = List.fold_right2 (StringMap.add)
                        built_in_decls_names
                        built_in_decls_funcs
                        (StringMap.singleton "print"
                                { typ = Void; fname = "print"; formals = [(MyString, "x")];
                                locals = []; body = [] })

  in

  let function_decls = List.fold_left (fun m fd -> StringMap.add fd.fname fd m)
                         built_in_decls functions

  in

  let function_decl s = try StringMap.find s function_decls
       with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let _ = function_decl "main" in (* Ensure "main" is defined *)

  let check_function func =

    List.iter (check_not_void (fun n -> "illegal void formal " ^ n ^
      " in " ^ func.fname)) func.formals;

    report_duplicate (fun n -> "duplicate formal " ^ n ^ " in " ^ func.fname)
      (List.map snd func.formals);

    List.iter (check_not_void (fun n -> "illegal void local " ^ n ^
      " in " ^ func.fname)) func.locals;

    report_duplicate (fun n -> "duplicate local " ^ n ^ " in " ^ func.fname)
      (List.map snd func.locals);

    (* Type of each variable (global, formal, or local *)
    let symbols = List.fold_left (fun m (t, n) -> StringMap.add n t m)
	StringMap.empty (globals @ func.formals @ func.locals )
    in

    let type_of_identifier s =
      try StringMap.find s symbols
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    (* Return the type of an expression or throw an exception *)
    let rec expr = function
	Literal _ -> Int
      | FloatLiteral _ -> Float
      | BoolLit _ -> Bool
      | MyStringLit _ -> MyString
      | Id s -> type_of_identifier s
      | Binop(e1, op, e2) as e -> let t1 = expr e1 and t2 = expr e2 in
	(match op with
          Add | Sub | Mult | Div  when t1 = Int && t2 = Int -> Int
        |  Add | Sub | Mult | Div  when t1 = Float && t2 = Float -> Float
	| Mod when t1 = Int && t2 = Int -> Int
	| Equal | Neq when t1 = t2 -> Bool
	| Less | Leq | Greater | Geq when t1 = Int && t2 = Int -> Bool
	| And | Or when t1 = Bool && t2 = Bool -> Bool
        | _ -> raise (Failure ("illegal binary operator " ^
              string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
              string_of_typ t2 ^ " in " ^ string_of_expr e))
        )
      | Dotop(e1, field) -> let lt = expr e1 in
       	 check_access (lt) (field)
      | Castop(t, _) -> (*check later*) t
      | Unop(op, e) as ex -> let t = expr e in
	 (match op with
	   Neg when t = Int -> Int
	 | Not when t = Bool -> Bool
         | Deref -> (match t with
		PointerType s -> s
		| _ -> raise (Failure("cannot dereference a " ^ string_of_typ t)) )
         | Ref -> PointerType(t) 
	 | _ -> raise (Failure ("illegal unary operator " ^ string_of_uop op ^
	  		   string_of_typ t ^ " in " ^ string_of_expr ex)))
      | Noexpr -> Void
     | Call(fname, actuals) as call -> let fd = function_decl fname in
     
         if List.length actuals != List.length fd.formals then
           raise (Failure ("expecting " ^ string_of_int
             (List.length fd.formals) ^ " arguments in " ^ string_of_expr call))
         else
           List.iter2 (fun (ft, _) e -> let et = expr e in
              ignore (check_assign ft et
                (Failure ("illegal actual argument found " ^ string_of_typ et ^
                " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e))))
             fd.formals actuals;
           fd.typ
      | Assign(e1, e2) as ex ->
	(match e1 with
		Id s -> 
 			let lt = type_of_identifier s and rt = expr e2 in
     			check_assign (lt) (rt) (Failure ("illegal assignment " ^ string_of_typ lt ^ " = " ^
                           string_of_typ rt ^ " in " ^ string_of_expr ex))
		|Unop(op, _) ->
			(match op with 
				Deref -> expr e2
				|_ -> raise(Failure("whatever"))
			)
		|Dotop (_, _) -> expr e2
		| _ -> raise (Failure("whatever"))
	)

     in

    let check_bool_expr e = if expr e != Bool
     then raise (Failure ("expected Boolean expression in " ^ string_of_expr e))
     else () in

    (* Verify a statement or throw an exception *)
    let rec stmt = function
	Block sl -> let rec check_block = function
           [Return _ as s] -> stmt s
         | Return _ :: _ -> raise (Failure "nothing may follow a return")
         | Block sl :: ss -> check_block (sl @ ss)
         | s :: ss -> stmt s ; check_block ss
         | [] -> ()
        in check_block sl
      | Expr e -> ignore (expr e)
      | Return e -> let t = expr e in if t = func.typ then () else
         raise (Failure ("return gives " ^ string_of_typ t ^ " expected " ^
                         string_of_typ func.typ ^ " in " ^ string_of_expr e))
           
      | If(p, b1, b2) -> check_bool_expr p; stmt b1; stmt b2
      | For(e1, e2, e3, st) -> ignore (expr e1); check_bool_expr e2;
                               ignore (expr e3); stmt st
      | While(p, s) -> check_bool_expr p; stmt s
    in

    stmt (Block func.body)
   
  in
  List.iter check_function functions
