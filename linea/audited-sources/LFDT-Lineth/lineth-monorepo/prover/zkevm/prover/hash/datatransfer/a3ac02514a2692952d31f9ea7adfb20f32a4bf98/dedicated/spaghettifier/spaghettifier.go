package spaghettifier

import (
	"github.com/consensys/zkevm-monorepo/prover/maths/common/smartvectors"
	"github.com/consensys/zkevm-monorepo/prover/maths/field"
	"github.com/consensys/zkevm-monorepo/prover/protocol/column"
	"github.com/consensys/zkevm-monorepo/prover/protocol/ifaces"
	"github.com/consensys/zkevm-monorepo/prover/protocol/wizard"
	sym "github.com/consensys/zkevm-monorepo/prover/symbolic"
	"github.com/consensys/zkevm-monorepo/prover/zkevm/prover/common"
)

// SpaghettificationInputs collects the arguments of the [NewSpaghettification]
// function.
type SpaghettificationInput struct {
	// Name carries a name to tag the Spaghettification process..
	Name string
	// ContentMatrix corresponds to the - possibly multicolumn - table of data to
	// spaghettify. The first level of slice list the different tables to be
	// spaghettify and the second level lists the columns for every tables.
	ContentMatrix [][]ifaces.Column
	// Filter is a - possibly fragmented - list of columns indicating the cells
	// of [ContentMatrix] ot include in the spaghettification.
	Filter []ifaces.Column
	// SpaghettiSize is the requested size of the spaghetti column to generate.
	SpaghettiSize int
}

// spaghettification is an implementation of the wizard.ProverAction. It
// represents a dedicated utility module that can collect the content of several
// columns and put them in order in the same column.
//
// This is used in part to align the raw data limbs to the same column so that
// we can pack them into chunks of equal byte size.
type spaghettification struct {
	// input stores the input that have been used to construct the struct.
	inputs SpaghettificationInput
	// tags for the filtered elements of the matrix
	tags []ifaces.Column
	// filterSpaghetti of the filter over the spaghettiOfMatrix. It has an
	// "isActive" structure. Meaning that it is assigned to contain a sequence
	// of 1's followed with 0's as padding
	filterSpaghetti ifaces.Column
	// tagSpaghetti is the spaghetti of the tags
	tagSpaghetti ifaces.Column
	// ContentSpaghetti stores the spaghettified of
	// [SpaghettificationInput.ContentMatrix]. This is the main result of the
	// operation.
	ContentSpaghetti []ifaces.Column
}

// Spaghettify generates and constrains the column required to instantiate a
// table spaghettification. The function returns a [spaghettification] object
// implementing the [wizard.ProverAction].
//
// Among the generated columns the columns [spaghettification.ContentSpaghetti]
// stores the required result.
func Spaghettify(comp *wizard.CompiledIOP, inputs SpaghettificationInput) *spaghettification {

	var (
		// pieceSize contains the number of a spaghetti fragment. They all have
		// the same size.
		pieceSize = inputs.Filter[0].Size()
		// numPiece contains the number of spaghetti fragment
		numPieces = len(inputs.Filter)
		// numColsInTable contains the number of columns in the table
		numColsInTable = len(inputs.ContentMatrix[0])
		// spaghetti stores the result of the spaghettification
		spaghetti = &spaghettification{
			inputs: inputs,
			tags:   make([]ifaces.Column, numPieces),
			filterSpaghetti: comp.InsertCommit(0,
				ifaces.ColIDf("%v_%v", inputs.Name, "FILTERS_SPAGHETTI"),
				inputs.SpaghettiSize,
			),
			ContentSpaghetti: make([]ifaces.Column, numColsInTable),
			tagSpaghetti: comp.InsertCommit(0,
				ifaces.ColIDf("%v_%v", inputs.Name, "TAGS_SPAGHETTI"),
				inputs.SpaghettiSize,
			),
		}
	)

	for pieceID := 0; pieceID < numPieces; pieceID++ {

		spaghetti.tags[pieceID] = comp.InsertCommit(0,
			ifaces.ColIDf("%v_%v_%v", inputs.Name, "TAGS", pieceID),
			pieceSize,
		)
	}

	for col := 0; col < numColsInTable; col++ {

		spaghetti.ContentSpaghetti[col] = comp.InsertCommit(0,
			ifaces.ColIDf("%v_%v_%v", inputs.Name, "CONTENT_SPAGHETTI", col),
			inputs.SpaghettiSize,
		)
	}

	spaghetti.csTags(comp)
	spaghetti.csTagSpaghetti(comp)
	spaghetti.csFilterSpaghetti(comp)
	spaghetti.csInclusion(comp)

	return spaghetti
}

// csTags adds constraints over the "tags" columns. The tag increase by 1 over
// the filterered element.
//
// NB: the very first value of the tags is not constrained. This is harmless
// as only the continuity between the tags is important.
func (sp *spaghettification) csTags(comp *wizard.CompiledIOP) {

	var (
		numPieces = len(sp.tags)
	)

	for i := 1; i < numPieces; i++ {

		// This ensures that the tags increases by 1 when walking through the
		// rows of the matrix.
		comp.InsertGlobal(0,
			ifaces.QueryIDf("%v_%v_%v", sp.inputs.Name, "TAGS_INCREASE_HORIZONTALLY", i),
			sym.Sub(
				sym.Sub(sp.tags[i], sp.tags[i-1]),
				sp.inputs.Filter[i-1],
			),
		)
	}

	// This ensures that the tags keep increasing as we enter the next line
	comp.InsertGlobal(0,
		ifaces.QueryIDf("%v_%v", sp.inputs.Name, "TAGS_INCREASE_JUMPING_NEXT_LINE"),
		sym.Sub(
			sym.Sub(sp.tags[0], column.Shift(sp.tags[numPieces-1], -1)),
			column.Shift(sp.inputs.Filter[numPieces-1], -1),
		),
	)

}

// csTagSpaghetti constrains the tagSpaghetti column to continuously increase.
func (sp *spaghettification) csTagSpaghetti(comp *wizard.CompiledIOP) {

	comp.InsertGlobal(0,
		ifaces.QueryIDf("%v_TAGS_SPAGHETTI_INCREASES", sp.inputs.Name),
		sym.Sub(
			sp.tagSpaghetti,
			sym.Mul(
				sym.Add(column.Shift(sp.tagSpaghetti, -1), 1),
				sp.filterSpaghetti,
			),
		),
	)
}

// csSpaghettiFilter constraints the filterSpaghetti column to be structured as
// a sequence of 1's followed by a zero-padding.
func (sp *spaghettification) csFilterSpaghetti(comp *wizard.CompiledIOP) {

	comp.InsertGlobal(0,
		ifaces.QueryIDf("%v_FILTER_SPAGHETTI_IS_BINARY", sp.inputs.Name),
		sym.Mul(
			sym.Sub(sp.filterSpaghetti, 1),
			sp.filterSpaghetti,
		),
	)

	comp.InsertGlobal(0,
		ifaces.QueryIDf("%v_FILTER_SPAGHETTI_NO_0_TO_1", sp.inputs.Name),
		sym.Mul(
			sp.filterSpaghetti,
			sym.Sub(1, column.Shift(sp.filterSpaghetti, -1)),
		),
	)
}

// csInclusion adds the bilateral inclusion queries enforcing that the spaghetti
// and the content filter contains the same data.
func (sp *spaghettification) csInclusion(comp *wizard.CompiledIOP) {

	var (
		numPieces      = len(sp.tags)
		inputTables    = make([][]ifaces.Column, numPieces)
		spaghettiTable = append(sp.ContentSpaghetti, sp.tagSpaghetti)
	)

	for pieceID := 0; pieceID < numPieces; pieceID++ {

		inputTables[pieceID] = append(sp.inputs.ContentMatrix[pieceID], sp.tags[pieceID])

		comp.GenericFragmentedConditionalInclusion(0,
			ifaces.QueryIDf("%v_SPAGHETTI_INCLUSION_%v", sp.inputs.Name, pieceID),
			[][]ifaces.Column{spaghettiTable},
			inputTables[pieceID],
			[]ifaces.Column{sp.filterSpaghetti},
			sp.inputs.Filter[pieceID],
		)
	}

	comp.GenericFragmentedConditionalInclusion(0,
		ifaces.QueryIDf("%v_SPAGHETTI_INCLUSION_BACKWARD", sp.inputs.Name),
		inputTables,
		spaghettiTable,
		sp.inputs.Filter,
		sp.filterSpaghetti,
	)
}

// Run implements the [wizard.ProverAction] interface
func (sp *spaghettification) Run(run *wizard.ProverRuntime) {

	var (
		numPieces            = len(sp.tags)
		pieceSize            = sp.tags[0].Size()
		nbCols               = len(sp.ContentSpaghetti)
		tags                 = make([]*common.VectorBuilder, numPieces)
		contentSpaghetti     = make([]*common.VectorBuilder, nbCols)
		filterSpaghetti      = common.NewVectorBuilder(sp.filterSpaghetti)
		tagSpaghetti         = common.NewVectorBuilder(sp.tagSpaghetti)
		content              = make([][]smartvectors.SmartVector, numPieces)
		filters              = make([]smartvectors.SmartVector, numPieces)
		currTag          int = 0
	)

	for pieceID := range tags {

		tags[pieceID] = common.NewVectorBuilder(sp.tags[pieceID])
		content[pieceID] = make([]smartvectors.SmartVector, nbCols)
		filters[pieceID] = sp.inputs.Filter[pieceID].GetColAssignment(run)

		for col := 0; col < nbCols; col++ {
			content[pieceID][col] = sp.inputs.ContentMatrix[pieceID][col].GetColAssignment(run)
		}
	}

	for i := range contentSpaghetti {
		contentSpaghetti[i] = common.NewVectorBuilder(sp.ContentSpaghetti[i])
	}

	for row := 0; row < pieceSize; row++ {
		for pieceID := 0; pieceID < numPieces; pieceID++ {

			f := filters[pieceID].Get(row)
			tags[pieceID].PushInt(currTag)

			if f.IsOne() {

				filterSpaghetti.PushOne()
				tagSpaghetti.PushInt(currTag)

				for col := 0; col < nbCols; col++ {
					contentSpaghetti[col].PushField(content[pieceID][col].Get(row))
				}

				currTag++
			}
		}
	}

	filterSpaghetti.PadAndAssign(run, field.Zero())
	tagSpaghetti.PadAndAssign(run, field.Zero())

	for pieceID := range tags {
		tags[pieceID].PadAndAssign(run, field.Zero())
	}

	for i := range contentSpaghetti {
		contentSpaghetti[i].PadAndAssign(run, field.Zero())
	}

}
