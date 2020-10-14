#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <erl_nif.h>
#include "cvtest.h"

static ERL_NIF_TERM test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	if(__builtin_expect(argc != 4, false)) {
		return enif_make_badarg(env);
	}
	ErlNifBinary file1;
	if(__builtin_expect(!enif_inspect_binary(env, argv[0], &file1), false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument(file1)");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);
	}
	ErlNifBinary file2;
	if(__builtin_expect(!enif_inspect_binary(env, argv[1], &file2), false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument(file2)");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);
	}
	unsigned len;
	if(__builtin_expect(!enif_get_atom_length(env, argv[2], &len, ERL_NIF_LATIN1), false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument(cuda?_not_atom)");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);		
	}
	char *buf = (char *)enif_alloc(sizeof(char) * (len + 1));
	if(__builtin_expect(buf == NULL, false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument(cuda?_cannot_alloc)");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);				
	}
	if(__builtin_expect(!enif_get_atom(env, argv[2], buf, len + 1, ERL_NIF_LATIN1), false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument(cuda?_not_atom_2)");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);				
	}
	bool is_cuda;
	if(strncmp(buf, "true", 4) == 0) {
		is_cuda = true;
	} else if(strncmp(buf, "false", 5) == 0) {
		is_cuda = false;
	} else {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument(cuda?_not_true_false)");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);				
	}
	uint64_t loop;
	if(__builtin_expect(!enif_get_uint64(env, argv[3], (ErlNifUInt64 *)&loop), false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument(loop)");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);				
	}
	double time;
	if(__builtin_expect(!cvtest(file1.size, file1.data, file2.size, file2.data, &time, is_cuda, loop), false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_file_not_found = enif_make_atom(env, "file_not_found");
		return enif_make_tuple(env, 2, atom_err, atom_file_not_found);
	}

	ERL_NIF_TERM atom_ok = enif_make_atom(env, "ok");
	return enif_make_tuple(env, 2, atom_ok, enif_make_double(env, time));
}

static ErlNifFunc nif_funcs[] =
{
	{"test", 4, test}
};

ERL_NIF_INIT(Elixir.ExcvTest, nif_funcs, NULL, NULL, NULL, NULL)
