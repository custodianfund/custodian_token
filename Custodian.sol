pragma solidity ^0.4.4;

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256 balance);
    function transfer(address to, uint256 value) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 value);
} 

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256 remaining);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function approve(address spender, uint256 value) public returns (bool success);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
  
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool success)  {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of. 
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance)  {
        return balances[_owner];
    }
 
}
 
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is ERC20, BasicToken {
 
    mapping (address => mapping (address => uint256)) allowed;

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amout of tokens to be transfered
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)  {
        uint256 _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool success)  {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifing the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
 
}
 
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
    address public owner;

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable()  public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) onlyOwner  public {
        require(newOwner != address(0));      
        owner = newOwner;
    }
 
}
 
/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 */
 
contract MintableToken is StandardToken, Ownable {
    
    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will recieve the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    /**
    * @dev Function to stop minting new tokens.
    * @return True if the operation was successful.
    */
    function finishMinting() public onlyOwner returns (bool)  {
        mintingFinished = true;
        MintFinished();
        return true;
    }
  
}
/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken, Ownable {
 
  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
    function burn(address burner, uint256 _value) public onlyOwner { 
        require(_value <= balances[burner]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        // address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        Transfer(burner, address(0), _value);
    }
 
    event Burn(address indexed burner, uint indexed value);
 
}

// Токен 
contract CSTToken is MintableToken, BurnableToken {
    
    string public constant name = "Custodian Token";
    
    string public constant symbol = "CST";
    
    uint32 public constant decimals = 18;

}

// Контракт краудсейла 
contract CSTCrowdsale is Ownable {
    using SafeMath for uint;

    address multisig;                                 // Адрес получателя эфира

    uint start;                                     // Таймштамп старта периода
    uint totalStart;                                 // Таймштамп запуска контракта
    uint period;                                     // Кол-во дней (в тестовом минут) проведения периода краудсейла
    uint public stage;                               // Номер периода
    uint mul;                                        // Множитель для разных этапов:     bcostReal = rate * mul

    uint public supplyLimit;                                 // Лимит выпуска токенов
    uint buyLimit;                                    // Лимит покупки токенов
    uint minLimit;                                    // Минимально для покупки
    uint minEth;                                    // Минимальное кол-во эфира для покупки

    CSTToken public token = new CSTToken();         // Токен

    uint public rate;                                         // Курс обмена на токены

    uint constant M = 1000000000000000000;            // 1 CST = 10^18 CSTunits

    // Проверка кол-ва выпущенных токенов
    modifier isUnderHardcap() {
        require(token.totalSupply() < supplyLimit);
        _;
    }

    modifier isHave(){
        require(msg.value >= minEth);
        _;
    }

    // Активен ли краудсейл
    modifier isActive() {
        require(now > start && now < start + period * 1 days);     // Для продакшена - поменять минуты на дни
        _;
    }

    // Выпустить токены на кошелек
    function mintFor(address _to, uint _val) public onlyOwner isActive payable {
        token.mint(_to, _val * M);
    }

    // Установить курс обмена
    function setRate(uint _rate) public onlyOwner {
        rate = _rate;
    }

    // Установить можитель
    function setMul(uint _mul) public onlyOwner {
        mul = _mul;
    }

    // Установить период (в днях) для текущего этапа
    function setPeriod(uint _periodId) public onlyOwner {
        period = _periodId;
    }

    // Установить минимальное кол-во ETH для покупки токенов
    function setMinEth(uint _eth) public onlyOwner {
        minEth = _eth;
    }

    // Установить этап:
    // 0 - Pre Sale
    // 1 - Pre ICO
    // 2 - ICO #1
    // 3 - ICO #2
    // 4 - ICO #3
    // 5 - ICO #4
    function setCurrentStage (uint _stage) public onlyOwner {
        if (_stage == 0) {
            stage = 0;
            period = 60;
            supplyLimit = 4000000 * M; // 4M tokens
            mul = 0;    // NO BONUS
            rate = M.mul(750); // 1 ETH = 375 USD = 750 CST (1 CST = 0.5 USD)
            start = now;
        }else if (_stage == 1) {
            stage = 1;
            period = 30;
            supplyLimit = 14000000 * M; // 10M + 4M (prev.) tokens
            // minLimit = 500000 * M;
            // buyLimit = 8000000 * M;
            mul = 0; // NO BONUS
            rate = M.mul(470); // 1 ETH = 375 USD = 470 CST (1 CST = 0,8 USD)
            start = now;
        }else if(_stage == 2) {
            stage = 2;
            period = 7;
            supplyLimit = 13411765 * M; // 9,411,765 + 4M tokens (~9.5 + 4 M)
            // minLimit = 500000 * M;
            // buyLimit = 8000000 * M;
            mul = 0;
            rate = M.mul(441); // 1 ETH = 375 USD = 441 CST (1 CST = 0,85 USD)
            start = now;
        }else if(_stage == 3) {
            stage = 3;
            period = 7;
            supplyLimit = 12888889 * M; // 8,888,889 + 4M tokens (~8.9 + 4 M)
            // minLimit = 500000 * M;
            // buyLimit = 8000000 * M;
            mul = 0;
            rate = M.mul(417); // 1 ETH = 375 USD = 417 CST (1 CST = 0,9 USD)
            start = now;
        }else if(_stage == 4) {
            stage = 4;
            period = 7;
            supplyLimit = 12421053 * M; // 8,421,053 + 4M tokens (~8.4 + 4 M)
            // minLimit = 500000 * M;
            // buyLimit = 8000000 * M;
            mul = 0;
            rate = M.mul(395); // 1 ETH = 375 USD = 374 CST (1 CST = 0,95 USD)
            start = now;
        }else if(_stage == 5) {
            stage = 5;
            period = 7;
            supplyLimit = 8000000 * M; // -- ????
            // minLimit = 500000 * M;
            // buyLimit = 8000000 * M;
            mul = 0;
            rate = M.mul(375); // 1 ETH = 375 USD = 375 CST (USD/CST = 1:1)
            start = now;
        }
    }

    // Изменить лимит выпуска токенов
    function modyfySupplyLimit(uint _new) public onlyOwner {
        if(_new >= token.totalSupply()){
            supplyLimit = _new;
        }
    }

    // Сжечь токены
    function burnTokens(uint _value) public onlyOwner {
        token.burn(msg.sender, _value);
    }

    // Получить время завешения текущего периода краудсейла
    function getPeriodEnding() public returns (uint endingTimestamp) {
        return start + period * 1 days;
    }

    // Получить состояние краудсейла
    function getPeriodStatus() public returns (bool crowdsaleActive) {
        return now > start && now < start + period * 1 days;
    }

    // 000000000000000000 - 18 нулей, добавить к сумме в целых CST
    // Старт пре-ICO
    function CSTCrowdsale() public {
        multisig = 0x6371c0841c170ea532e83e38595a22C95EC3e48F;         // Записываем адрес, на который будет пересылаться эфир
        // multisig = 0x16A49c8aF25B3c2fF315934Bf38A4CF645813844; // Dev
        totalStart = now;            // Записываем дату деплоя
        // Запускаем PreSale
        minEth = 1 ether;
        minEth = minEth.div(10);
        stage = 0;
        period = 60;
        supplyLimit = 4000000 * M; // 4M tokens
        mul = 0;    // NO BONUS
        rate = M.mul(750); // 1 ETH = 375 USD = 750 CST (1 CST = 0.5 USD)
        start = now;
    }
    
    // Автоматическая покупка токенов    
    function createTokens() public isUnderHardcap isActive isHave payable {
        uint tokens = rate.mul(msg.value).div(1 ether);             // Переводим ETH в CST

        // if(now <= start + period * 1 days) {            // Начисляем бонус
        //     tokens = tokens + tokens.div(100).mul(mul);
        // }
        // require(tokens > minLimit && tokens < buyLimit);
        require(token.totalSupply() + tokens <= supplyLimit);
        multisig.transfer(msg.value);                 // переводим на основной кошелек
        token.mint(msg.sender, tokens);             // Начисляем
        
    }

    // Прекратить выпуск токенов
    // ВНИМАНИЕ! После вызова этой функции перезапуск будет невозможен!
    function closeMinting() public onlyOwner {
        token.finishMinting();
    }

    // Если кто-то перевел эфир на контракт
    function() external payable {
        createTokens(); // Вызываем функцию начисления токенов
    }

}