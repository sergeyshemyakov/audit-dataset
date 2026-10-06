package internal

import "github.com/consensys/gnark/frontend"

func AssertSliceEquals(api frontend.API, a, b []frontend.Variable) {
	api.AssertIsEqual(len(a), len(b)) // TODO checked in compile time?
	for i := range a {
		api.AssertIsEqual(a[i], b[i])
	}
}
