import { getters } from '../../src/store/historical_games.js'

const createState = () => ({ ids: [], all: {} })

describe('historicalGames', () => {
  describe('getters', () => {
    describe('byTeamId', () => {
      it('returns games team participated in', () => {
        const state = createState()
        state.ids = [1, 2, 3]
        state.all = {
          '1': { blueSideTeamId: 1, redSideTeamId: 2 },
          '2': { blueSideTeamId: 1, redSideTeamId: 3 },
          '3': { blueSideTeamId: 2, redSideTeamId: 4 },
        }

        const actual = getters.byTeamId(state)(1)

        expect(actual).toEqual([ state.all['1'], state.all['2'] ])
      })
    })
  })
})
