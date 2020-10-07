#include <stdbool.h>
#include <stdlib.h>
#include <erl_nif.h>

static ERL_NIF_TERM test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	if(__builtin_expect(argc != 1, false)) {
		return enif_make_badarg(env);
	}
	ERL_NIF_TERM atom_err = enif_make_atom(env, "error");
	ERL_NIF_TERM atom_not_implemented = enif_make_atom(env, "not_implemented");
	return enif_make_tuple(env, 2, atom_err, atom_not_implemented);
}

static ErlNifFunc nif_funcs[] =
{
	{"test", 1, test}
};

ERL_NIF_INIT(Elixir.ExcvTest, nif_funcs, NULL, NULL, NULL, NULL)
