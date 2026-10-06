package keccak

/* TODO delete entire file
type fibVerifierCircuit struct {
	WizardVerifier *wizard.WizardVerifierCircuit
	P              []frontend.Variable
}

func (Compiled *fibVerifierCircuit) Define(api frontend.API) error {
	Compiled.WizardVerifier.Verify(api)
	p := Compiled.WizardVerifier.GetColumn("P1")
	if len(p) != len(Compiled.P) {
		return errors.New("column length mismatch")
	}
	for i := range p {
		api.AssertIsEqual(Compiled.P[i], p[i])
	}
	return nil
}

func defineFib2(b *wizard.Builder) {
	const N = 4
	p1 := b.RegisterCommit("P1", N)
	b.Columns.SetStatus("P1", column.Proof)
	expr := ifaces.ColumnAsVariable(column.Shift(p1, -1)).
		Add(ifaces.ColumnAsVariable(column.Shift(p1, -2))).
		Sub(ifaces.ColumnAsVariable(p1))

	b.GlobalConstraint("GLOBAL1", expr)
}

func TestVerifyFibInGnark(t *testing.T) {
	compiled := wizard.Compile(defineFib2, compiler.Arcane(8, 8), vortex.Compile(2))
	proof := wizard.Prove(compiled, proveFibGood)
	assert.NoError(t, wizard.Verify(compiled, proof))
	subc, err := wizard.AllocateWizardCircuit(compiled)
	assert.NoError(t, err)
	circuit := fibVerifierCircuit{
		WizardVerifier: subc,
		P:              make([]frontend.Variable, 4),
	}
	assignment := fibVerifierCircuit{
		WizardVerifier: wizard.GetWizardVerifierCircuitAssignment(compiled, proof),
		P:              []frontend.Variable{1, 1, 2, 3},
	}

	cs, err := frontend.Compile(ecc.BLS12_377.ScalarField(), scs.NewBuilder, &circuit)
	assert.NoError(t, err)

	w, err := frontend.NewWitness(&assignment, ecc.BLS12_377.ScalarField())
	assert.NoError(t, err)

	Compiled, l, err := unsafekzg.NewSRS(cs)
	assert.NoError(t, err)

	pk, vk, err := plonk.Setup(cs, Compiled, l)
	assert.NoError(t, err)

	opts := gkrmimc.SolverOpts(cs)
	plonkProof, err := plonk.Prove(cs, pk, w, backend.WithSolverOptions(opts...))
	assert.NoError(t, err)

	w, err = w.Public()
	assert.NoError(t, err)

	assert.NoError(t, plonk.Verify(plonkProof, vk, w))
}
*/
