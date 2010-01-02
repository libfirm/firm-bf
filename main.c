#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include <libfirm/firm.h>
#include <libfirm/be.h>

/** the main function will use 1 local variable */
#define MAIN_LOCAL_VARS       1
/** the brainfuck programm will get 30000 bytes of storage */
#define DATA_SIZE             30000
/** the variable number of "the pointer" (the position in the data) */
#define VARIABLE_NUM_POINTER  0
/** commandline used for linking */
#define LINK_COMMAND          "gcc a.s"

static FILE *input;

static void initialize_firm(void)
{
	be_opt_register();

	firm_parameter_t params;
	memset(&params, 0, sizeof(params));
	params.size = sizeof(params);

	ir_init(&params);
}

/**
 * Create and setup the graph for the main function
 */
static ir_graph *create_graph(void)
{
	/* the identifier for the "main" function */
	/* create a new method type for the main function, no parameters,
	 * one result */
	ident   *type_id     = new_id_from_str("main_method_type");
	ir_type *method_type = new_type_method(type_id, 0, 1);

	ident   *int_id   = new_id_from_str("type_int");
	ir_type *type_int = new_type_primitive(int_id, mode_Is);
	set_method_res_type(method_type, 0, type_int);

	/* create an entity for the method in the global namespace */
	ident     *id          = new_id_from_str("main");
	ir_type   *global_type = get_glob_type();
	ir_entity *entity      = new_entity(global_type, id, method_type);

	/* now we can create a new graph */
	ir_graph *irg = new_ir_graph(entity, MAIN_LOCAL_VARS);

	/* the function should be visible to the linker, and use symbol "main"
	 * in linker */
	set_entity_visibility(entity, visibility_external_visible);
	set_entity_ld_ident(entity, id);

	return irg;
}

/**
 * setup the entity that represents the data usable by the brainfuck program.
 */
static ir_entity *create_field(void)
{
	ident   *byte_id   = new_id_from_str("type_byte");
	ir_type *byte_type = new_type_primitive(byte_id, mode_Bu);

	ident   *array_type_id = new_id_from_str("type_array");
	ir_type *array_type    = new_type_array(array_type_id, 1, byte_type);
	set_array_bounds_int(array_type, 0, 0, DATA_SIZE);

	set_type_size_bytes(array_type, DATA_SIZE);
	set_type_state(array_type, layout_fixed);

	ident     *id          = new_id_from_str("data");
	ir_type   *global_type = get_glob_type();
	ir_entity *entity      = new_entity(global_type, id, array_type);

	set_entity_visibility(entity, visibility_local);

	return entity;
}

static ir_entity *create_putchar_entity(void)
{
	ident   *int_id   = new_id_from_str("type_int");
	ir_type *type_int = new_type_primitive(int_id, mode_Is);

	ident   *type_id     = new_id_from_str("type_putchar");
	ir_type *method_type = new_type_method(type_id, 1, 1);
	
	set_method_res_type(method_type, 0, type_int);
	set_method_param_type(method_type, 0, type_int);

	ident     *id          = new_id_from_str("putchar");
	ir_type   *global_type = get_glob_type();
	ir_entity *entity      = new_entity(global_type, id, method_type);
	set_entity_visibility(entity, visibility_external_allocated);
	set_entity_ld_ident(entity, id);

	return entity;
}

static ir_entity *create_getchar_entity(void)
{
	ident   *int_id   = new_id_from_str("type_int");
	ir_type *type_int = new_type_primitive(int_id, mode_Is);

	ident   *type_id     = new_id_from_str("type_getchar");
	ir_type *method_type = new_type_method(type_id, 0, 1);
	
	set_method_res_type(method_type, 0, type_int);

	ident     *id          = new_id_from_str("getchar");
	ir_type   *global_type = get_glob_type();
	ir_entity *entity      = new_entity(global_type, id, method_type);
	set_entity_visibility(entity, visibility_external_allocated);
	set_entity_ld_ident(entity, id);

	return entity;
}

static void increase_pointer(void)
{
	ir_node *pointer_value = get_value(VARIABLE_NUM_POINTER, mode_P_data);

	tarval  *value_one = new_tarval_from_long(1, mode_Is);
	ir_node *one       = new_Const(value_one);
	
	ir_node *add = new_Add(pointer_value, one, mode_P_data);

	set_value(VARIABLE_NUM_POINTER, add);
}

static void decrease_pointer(void)
{
	ir_node *pointer_value = get_value(VARIABLE_NUM_POINTER, mode_P_data);

	tarval  *value_one = new_tarval_from_long(1, mode_Is);
	ir_node *one       = new_Const(value_one);
	
	ir_node *sub = new_Sub(pointer_value, one, mode_P_data);

	set_value(VARIABLE_NUM_POINTER, sub);
}

static void increment_byte(void)
{
	ir_node *pointer_value = get_value(VARIABLE_NUM_POINTER, mode_P_data);

	ir_node *mem  = get_store();
	ir_node *load = new_Load(mem, pointer_value, mode_Bu, cons_none);

	ir_node *load_result = new_Proj(load, mode_Bu, pn_Load_res);
	ir_node *load_mem    = new_Proj(load, mode_M, pn_Load_M);

	tarval  *value_one = new_tarval_from_long(1, mode_Bu);
	ir_node *one       = new_Const(value_one);

	ir_node *add       = new_Add(load_result, one, mode_Bu);

	ir_node *store     = new_Store(load_mem, pointer_value, add, cons_none);
	ir_node *store_mem = new_Proj(store, mode_M, pn_Store_M);

	set_store(store_mem);
}

static void decrement_byte(void)
{
	ir_node *pointer_value = get_value(VARIABLE_NUM_POINTER, mode_P_data);

	ir_node *mem  = get_store();
	ir_node *load = new_Load(mem, pointer_value, mode_Bu, cons_none);

	ir_node *load_result = new_Proj(load, mode_Bu, pn_Load_res);
	ir_node *load_mem    = new_Proj(load, mode_M, pn_Load_M);

	tarval  *value_one = new_tarval_from_long(1, mode_Bu);
	ir_node *one       = new_Const(value_one);

	ir_node *add       = new_Sub(load_result, one, mode_Bu);

	ir_node *store     = new_Store(load_mem, pointer_value, add, cons_none);
	ir_node *store_mem = new_Proj(store, mode_M, pn_Store_M);

	set_store(store_mem);
}

static void output_byte(void)
{
	static ir_node   *putchar = NULL;
	static ir_entity *entity  = NULL;
	if(putchar == NULL) {
		entity  = create_putchar_entity();
		putchar = new_SymConst(mode_P, (union symconst_symbol) entity,
		                       symconst_addr_ent);
	}

	ir_node *pointer_value = get_value(VARIABLE_NUM_POINTER, mode_P_data);
	ir_node *mem           = get_store();

	ir_node *load        = new_Load(mem, pointer_value, mode_Bu, cons_none);
	ir_node *load_result = new_Proj(load, mode_Bu, pn_Load_res);

	ir_node *convert     = new_Conv(load_result, mode_Is);

	ir_node *in[] = { convert };
	ir_type *type = get_entity_type(entity);
	ir_node *call = new_Call(mem, putchar, 1, in, type);

	ir_node *call_mem = new_Proj(call, mode_M, pn_Call_M);

	set_store(call_mem);
}

static void input_byte(void)
{
	static ir_node   *getchar = NULL;
	static ir_entity *entity  = NULL;
	if(getchar == NULL) {
		entity  = create_getchar_entity();
		getchar = new_SymConst(mode_P, (union symconst_symbol) entity,
		                       symconst_addr_ent);
	}

	ir_node *mem = get_store();

	ir_type *type = get_entity_type(entity);
	ir_node *call = new_Call(mem, getchar, 0, NULL, type);

	ir_node *call_mem = new_Proj(call, mode_M, pn_Call_M);

	ir_node *call_results = new_Proj(call, mode_T, pn_Call_T_result);
	ir_node *call_result  = new_Proj(call_results, mode_Is, 0);

	ir_node *pointer_value = get_value(VARIABLE_NUM_POINTER, mode_P_data);
	ir_node *convert       = new_Conv(call_result, mode_Is);

	ir_node *store     = new_Store(call_mem, pointer_value, convert, cons_none);
	ir_node *store_mem = new_Proj(store, mode_M, pn_Store_M);

	set_store(store_mem);
}

static void create_return(void)
{
	ir_node *mem         = get_store();
	tarval  *value_zero  = new_tarval_from_long(0, mode_Is);
	ir_node *zero        = new_Const(value_zero);
	ir_node *return_node = new_Return(mem, 1, &zero);

	ir_node *end_block   = get_cur_end_block();
	add_immBlock_pred(end_block, return_node);

	mature_immBlock(get_cur_block());
	set_cur_block(NULL);
}

static void parse(void);

static void parse_loop(void)
{
	ir_node *jump = new_Jmp();
	mature_immBlock(get_cur_block());

	ir_node *loop_header_block = new_immBlock();
	add_immBlock_pred(loop_header_block, jump);
	set_cur_block(loop_header_block);

	ir_node *pointer_value = get_value(VARIABLE_NUM_POINTER, mode_P_data);

	ir_node *mem  = get_store();
	ir_node *load = new_Load(mem, pointer_value, mode_Bu, cons_none);

	ir_node *load_result = new_Proj(load, mode_Bu, pn_Load_res);
	ir_node *load_mem    = new_Proj(load, mode_M, pn_Load_M);

	set_store(load_mem);

	tarval  *value_zero = new_tarval_from_long(0, mode_Bu);
	ir_node *zero       = new_Const(value_zero);

	ir_node *cmp        = new_Cmp(load_result, zero);
	ir_node *equal      = new_Proj(cmp, mode_b, pn_Cmp_Eq);
	ir_node *cond       = new_Cond(equal);
	ir_node *proj_true  = new_Proj(cond, mode_X, pn_Cond_true);
	ir_node *proj_false = new_Proj(cond, mode_X, pn_Cond_false);

	ir_node *loop_body_block = new_immBlock();
	add_immBlock_pred(loop_body_block, proj_false);
	set_cur_block(loop_body_block);

	parse();

	if(feof(input)) {
		fprintf(stderr, "parse error: unmatched '['\n");
	}

	ir_node *jump2 = new_Jmp();
	add_immBlock_pred(loop_header_block, jump2);
	mature_immBlock(loop_header_block);
	mature_immBlock(get_cur_block());

	ir_node *after_loop_block = new_immBlock();
	add_immBlock_pred(after_loop_block, proj_true);
	set_cur_block(after_loop_block);
}

static void parse(void)
{
	while(!feof(input)) {
		int c = fgetc(input);
		switch(c) {
		case '>': increase_pointer(); break;
		case '<': decrease_pointer(); break;
		case '+': increment_byte(); break;
		case '-': decrement_byte(); break;
		case '.': output_byte(); break;
		case ',': input_byte(); break;
		case '[': parse_loop(); break;
		case ']': return;
		default: break;
		}
	}
}

int main(int argc, char **argv)
{
	if(argc != 2) {
		fprintf(stderr, "Usage: %s source.bf\n", argv[0]);
		return 1;
	}
	input = fopen(argv[1], "r");
	if(input == NULL) {
		fprintf(stderr, "Couldn't open '%s': %s\n", argv[1], strerror(errno));
		return 1;
	}

	initialize_firm();
	current_ir_graph = create_graph();

	/* "the pointer" will be constructed as variable number 0.
	 * It is initially set to the beginning of the array
	 */
	ir_entity *field       = create_field();
	ir_node   *field_start = new_SymConst(mode_P, (union symconst_symbol) field,
	                                      symconst_addr_ent);
	set_value(VARIABLE_NUM_POINTER, field_start);

	while(1) {
		parse();
		if(!feof(input)) {
			fprintf(stderr, "warning: unexpected ']'\n");
			continue;
		}
		break;
	}
	fclose(input);

	create_return();

	ir_node *end_block = get_cur_end_block();
	mature_immBlock(end_block);

	ir_type *frame_type = get_irg_frame_type(current_ir_graph);
	set_type_size_bytes(frame_type, 0);
	set_type_alignment_bytes(frame_type, 4);
	set_type_state(frame_type, layout_fixed);

	irp_finalize_cons();

	irg_vrfy(current_ir_graph);

	optimize_reassociation(current_ir_graph);
	optimize_load_store(current_ir_graph);
	optimize_graph_df(current_ir_graph);
	place_code(current_ir_graph);
	optimize_reassociation(current_ir_graph);
	optimize_graph_df(current_ir_graph);
	opt_jumpthreading(current_ir_graph);
	optimize_graph_df(current_ir_graph);

	FILE *out = fopen("a.s", "w");
	if(out == NULL) {
		fprintf(stderr, "couldn't open a.s for writing: %s\n", strerror(errno));
		return 1;
	}

	be_main(out, argv[1]);
	fclose(out);

	system(LINK_COMMAND);

	return 0;
}

