#include <stdbool.h>
#include <stdlib.h>
#include <erl_nif.h>
#include "cvtest.h"

static ERL_NIF_TERM test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	if(__builtin_expect(argc != 1, false)) {
		return enif_make_badarg(env);
	}
	ErlNifBinary file;
	if(__builtin_expect(!enif_inspect_binary(env, argv[0], &file), false)) {
		ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
		ERL_NIF_TERM atom_invalid_argument = enif_make_atom(env, "invalid_argument");
		return enif_make_tuple(env, 2, atom_err, atom_invalid_argument);
	}
	cvtest(file.size, file.data);

	ERL_NIF_TERM atom_ok = enif_make_atom(env, "ok");
	return enif_make_tuple(env, 2, atom_ok, atom_ok);
}

static ErlNifFunc nif_funcs[] =
{
	{"test", 1, test}
};

ERL_NIF_INIT(Elixir.ExcvTest, nif_funcs, NULL, NULL, NULL, NULL)
