import json

from google.appengine.ext import ndb


class BaseModel(ndb.Model):
    created = ndb.DateTimeProperty(auto_now_add=True)
    modified = ndb.DateTimeProperty(auto_now=True)


class Game(BaseModel):
    red_hash = ndb.StringProperty()
    blue_hash = ndb.StringProperty()
    join_hash = ndb.StringProperty()

    board = ndb.JsonProperty(default='''[
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
            [0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        ]''')

    red_setup = ndb.JsonProperty()
    blue_setup = ndb.JsonProperty()

    last_move = ndb.JsonProperty()

    # Who's turn is it currently? False = red, True = blue
    turn = ndb.BooleanProperty(default=False)

    # Is this game by invite only?
    private = ndb.BooleanProperty(default=True)

    # def _pre_put_hook(self):
    #     self.red_hash = uuid.uuid4().hex[:6]
    #     self.blue_hash = uuid.uuid4().hex[:6]
    #     self.join_hash = uuid.uuid4().hex[:6]

    def set_red_setup(self, red_setup):
        if not self.red_setup:
            board = self.get_board()

            board[6] = red_setup[0]
            board[7] = red_setup[1]
            board[8] = red_setup[2]
            board[9] = red_setup[3]

            self.set_board(board)
            self.red_setup = json.dumps(red_setup)
        else:
            raise AttributeError('yeah see...')

    def set_blue_setup(self, blue_setup):
        if not self.blue_setup:
            board = self.get_board()

            board[3] = blue_setup[0]
            board[2] = blue_setup[1]
            board[1] = blue_setup[2]
            board[0] = blue_setup[3]

            self.set_board(board)
            self.blue_setup = json.dumps(blue_setup)
        else:
            raise AttributeError('yeah see...')

    def get_opponent_hash(self, player_hash):
        if player_hash == self.blue_hash:
            return self.red_hash
        elif player_hash == self.red_hash:
            return self.blue_hash

    def get_board(self):
        return json.loads(self.board)

    def set_board(self, board):
        self.board = json.dumps(board)

    def set_last_move(self, fromPos, toPos):
        last_move = {
            'from': fromPos,
            'to': toPos
        }
        self.last_move = json.dumps(last_move)

    def move(self, fromPos, toPos):
        board = self.get_board()
        piece = board[fromPos['y']][fromPos['x']]

        board[fromPos['y']][fromPos['x']] = 0

        board[toPos['y']][toPos['x']] = piece

        self.set_board(board)

        # Flip the turn
        self.turn = not self.turn

        # Set last moved
        self.set_last_move(fromPos, toPos)

        return True

    def _canMove(fromPos, toPos):
        pass

    def _isPieceBetween(fromPos, toPos, diff):
        pass

    def _attack(fromPos, toPos):
        pass
