import { mutations, getters } from '../../../src/store/scheduled_games'
import { IScheduledGamesState } from '../../../src/store/types'

const createState = (): IScheduledGamesState => ({ ids: [], all: {} })

const GAME_ID_1 = 100
const GAME_ID_2 = 200
const GAME_ID_3 = 300
const TEAM_ID_1 = 111
const SUMMER_SPLIT_ID = 1
const SPRING_SPLIT_ID = 2

const data = { redSideTeamId: 1, blueSideTeamId: 2, id: 0, createdAt: new Date(), updatedAt: new Date(), date: new Date() }

const summerSplitGame = { id: GAME_ID_1, splitId: SUMMER_SPLIT_ID }
const springSplitGame = { ...data, id: GAME_ID_2, splitId: SPRING_SPLIT_ID }

const summerSplitGameWk1 =  {...data, ...summerSplitGame, createdAt: new Date(2018, 2, 1)}
const summerSplitGameWk3 =  {...data, ...summerSplitGame, id: GAME_ID_3, createdAt: new Date(2018, 2, 7)}

const response = [
  { id: GAME_ID_1, blueSideTeamId: 1, splitId: SUMMER_SPLIT_ID },
  { id: GAME_ID_2, blueSideTeamId: 2, splitId: SPRING_SPLIT_ID }
]

describe('mutations', () => {
  describe('SET_GAMES', () => {
    it('sets games and ids', () => {
      const state = createState()

      mutations.SET_GAMES(state, response)

      expect(state.ids).toEqual([GAME_ID_1, GAME_ID_2])
      expect(Object.keys(state.all)).toEqual([
        GAME_ID_1.toString(), GAME_ID_2.toString()
      ])
    })
  })
})

describe('getters', () => {
  describe('bySplitId', () => {
    it('returns games by split id', () => {
      const state = createState()
      // @ts-ignore
      state.ids = [GAME_ID_3, GAME_ID_1, GAME_ID_2]
      state.all = {
        [GAME_ID_1]: summerSplitGameWk1,
        [GAME_ID_2]: springSplitGame,
        [GAME_ID_3]: summerSplitGameWk3
      }

      const actual = getters.bySplitId(state, {}, {}, {})(SUMMER_SPLIT_ID)
      expect(actual).toEqual([GAME_ID_1, GAME_ID_3])
    })
  })

  describe('byTeamId', () => {
    it('returns games by a team id', () => {
      const state = createState()
      // @ts-ignore
      state.ids = [GAME_ID_1, GAME_ID_2, GAME_ID_3]
      state.all = {
        [GAME_ID_1]: { ...data, blueSideTeamId: TEAM_ID_1, redSideTeamId: 2 },
        [GAME_ID_2]: { ...data, blueSideTeamId: TEAM_ID_1, redSideTeamId: 3 },
        [GAME_ID_3]: { ...data, blueSideTeamId: 2, redSideTeamId: 4 },
      }

      const actual = getters.byTeamId(state, {}, {}, {})(TEAM_ID_1)

      // @ts-ignore
      expect(actual).toEqual([ state.all[GAME_ID_1], state.all[GAME_ID_2] ])
    })
  })

  describe('orderedByDate', () => {
    it('returns a list of all matches ordered by date', () => {
      const state = createState()
      // @ts-ignore
      state.ids = [GAME_ID_1, GAME_ID_2, GAME_ID_3]
      state.all = {
        [GAME_ID_2]: { ...data, gameNumber: 1, date: new Date(2018, 1, 1, 21) },
        [GAME_ID_1]: { ...data, gameNumber: 1, date: new Date(2018, 1, 1, 20) },
        [GAME_ID_3]: { ...data, gameNumber: 2 }
      }

      const actual = getters.orderedByDate(state, {}, {}, {})

      expect(actual).toEqual([ GAME_ID_1, GAME_ID_2 ])
    })
  })
})
